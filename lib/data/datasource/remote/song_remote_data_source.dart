import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

class SongRemoteDataSource {
  final _db = FirebaseFirestore.instance;

  // ── Cloudinary: upload ảnh, trả về URL ──
  Future<String> uploadImage(XFile imageFile) async {
    const cloudName = 'ddy9wgrbj'; // 👈 thay bằng Cloud Name của bạn
    const uploadPreset = 'musicapp'; // 👈 thay bằng tên upload preset

    return _uploadToCloudinary(
      file: imageFile,
      cloudName: cloudName,
      uploadPreset: uploadPreset,
      resourceType: 'image',
      fallbackFileName: 'cover.jpg',
    );
  }

  // ── Cloudinary: upload audio, trả về URL ──
  Future<String> uploadAudio(XFile audioFile) async {
    const cloudName = 'ddy9wgrbj'; // 👈 thay bằng Cloud Name của bạn
    const uploadPreset = 'musicapp'; // 👈 thay bằng tên upload preset

    return _uploadToCloudinary(
      file: audioFile,
      cloudName: cloudName,
      uploadPreset: uploadPreset,
      resourceType: 'video',
      fallbackFileName: 'audio.mp3',
    );
  }

  Future<String> _uploadToCloudinary({
    required XFile file,
    required String cloudName,
    required String uploadPreset,
    required String resourceType,
    required String fallbackFileName,
  }) async {
    final uri = Uri.parse(
      'https://api.cloudinary.com/v1_1/$cloudName/$resourceType/upload',
    );
    final request = http.MultipartRequest('POST', uri)
      ..fields['upload_preset'] = uploadPreset
      ..files.add(
        http.MultipartFile.fromBytes(
          'file',
          await file.readAsBytes(),
          filename: file.name.isNotEmpty ? file.name : fallbackFileName,
        ),
      );

    final response = await request.send();
    final body = await response.stream.bytesToString();
    final json = jsonDecode(body);

    if (response.statusCode >= 400 || json['secure_url'] == null) {
      final message =
          (json['error']?['message'] as String?) ?? 'Upload file thất bại';
      throw Exception(message);
    }

    return json['secure_url'] as String;
  }

  // ── Firestore: thêm bài hát ──
  Future<void> addSong(Map<String, dynamic> data) async {
    await _db.collection('songs').add(data);
  }

  // ── Firestore: cập nhật bài hát ──
  Future<void> updateSong(String id, Map<String, dynamic> data) async {
    await _db.collection('songs').doc(id).update(data);
  }

  // ── Firestore: xoá bài hát ──
  Future<void> deleteSong(String id) async {
    await _db.collection('songs').doc(id).delete();
  }

  // ── Firestore: lắng nghe danh sách realtime ──
  Stream<QuerySnapshot> getSongsStream() {
    return _db.collection('songs').orderBy('title').snapshots();
  }
}
