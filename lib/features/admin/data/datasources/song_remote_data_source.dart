import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;

class SongRemoteDataSource {
  static const _cloudName = 'ddy9wgrbj';
  static const _uploadPreset = 'musicapp';
  static const musicFolder = 'music';

  final _db = FirebaseFirestore.instance;

  // ── Cloudinary: upload ảnh, trả về URL ──
  Future<String> uploadImage(String localPath) async {
    final multipartFile = await http.MultipartFile.fromPath('file', localPath);

    return _uploadFile(
      resourceType: 'image',
      file: multipartFile,
      folderPath: musicFolder,
    );
  }

  // ── Cloudinary: upload audio, trả về URL ──
  Future<String> uploadAudio(String localPath) async {
    final multipartFile = await http.MultipartFile.fromPath('file', localPath);

    return _uploadFile(
      resourceType: 'video',
      file: multipartFile,
      folderPath: musicFolder,
    );
  }

  Future<String> _uploadFile({
    required String resourceType,
    required http.MultipartFile file,
    required String folderPath,
  }) async {
    final uri = Uri.parse(
      'https://api.cloudinary.com/v1_1/$_cloudName/$resourceType/upload',
    );
    final request = http.MultipartRequest('POST', uri)
      ..fields['upload_preset'] = _uploadPreset
      ..fields['folder'] = folderPath
      ..fields['asset_folder'] = folderPath
      ..fields['public_id_prefix'] = folderPath
      ..files.add(file);

    final response = await request.send();
    final body = await response.stream.bytesToString();
    final json = jsonDecode(body) as Map<String, dynamic>;

    if (response.statusCode < 200 || response.statusCode >= 300) {
      final errorMessage =
          (json['error'] as Map<String, dynamic>?)?['message']?.toString() ??
          'Upload Cloudinary thất bại';
      throw Exception(errorMessage);
    }

    final secureUrl = json['secure_url']?.toString();
    if (secureUrl == null || secureUrl.isEmpty) {
      throw Exception('Cloudinary không trả về secure_url');
    }

    return secureUrl;
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
