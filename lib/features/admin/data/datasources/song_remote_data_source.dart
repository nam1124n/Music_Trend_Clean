import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;

class SongRemoteDataSource {
  final _db = FirebaseFirestore.instance;

  // ── Cloudinary: upload ảnh, trả về URL ──
  Future<String> uploadImage(String localPath) async {
    const cloudName = 'ddy9wgrbj'; // 👈 thay bằng Cloud Name của bạn
    const uploadPreset = 'musicapp'; // 👈 thay bằng tên upload preset

    final uri = Uri.parse(
      'https://api.cloudinary.com/v1_1/$cloudName/image/upload',
    );
    final request = http.MultipartRequest('POST', uri)
      ..fields['upload_preset'] = uploadPreset
      ..files.add(await http.MultipartFile.fromPath('file', localPath));

    final response = await request.send();
    final body = await response.stream.bytesToString();
    final json = jsonDecode(body);

    return json['secure_url']; // URL ảnh trả về
  }

  // ── Cloudinary: upload audio, trả về URL ──
  Future<String> uploadAudio(String localPath) async {
    const cloudName = 'YOUR_CLOUD_NAME'; // 👈 thay bằng Cloud Name của bạn
    const uploadPreset = 'musicapp'; // 👈 thay bằng tên upload preset

    // Cloudinary dùng resource_type 'video' cho cả audio lẫn video
    final uri = Uri.parse(
      'https://api.cloudinary.com/v1_1/$cloudName/video/upload',
    );
    final request = http.MultipartRequest('POST', uri)
      ..fields['upload_preset'] = uploadPreset
      ..files.add(await http.MultipartFile.fromPath('file', localPath));

    final response = await request.send();
    final body = await response.stream.bytesToString();
    final json = jsonDecode(body);

    return json['secure_url']; // URL audio trả về
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
