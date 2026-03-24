import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:login_flutter/data/dto/profile/profile_model.dart';

abstract class ProfileRemoteDataSource {
  Future<void> updateAvatarUrl(String url);
  Future<ProfileModel> getProfile();
}

class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSource {
  final _db = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  @override
  Future<void> updateAvatarUrl(String url) async {
    final user = _auth.currentUser;
    if (user != null) {
      await _db.collection('users').doc(user.uid).set({
        'avatarUrl': url,
      }, SetOptions(merge: true));
    } else {
      throw Exception('Vui lòng đăng nhập trước khi thực hiện.');
    }
  }

  @override
  Future<ProfileModel> getProfile() async {
    final user = _auth.currentUser;
    if (user != null) {
      final doc = await _db.collection('users').doc(user.uid).get();
      final data = doc.data() ?? {};
      
      // Giữ lại mock data cho những chỉ số để giao diện hiển thị đẹp như cũ
      return ProfileModel(
        username: user.displayName ?? '@user_${user.uid.substring(0, 5)}',
        id: user.uid,
        avatarUrl: data['avatarUrl'] ?? '',
        followers: data['followers'] ?? 1200,
        following: data['following'] ?? 450,
        likes: data['likes'] ?? 15000,
      );
    } else {
      throw Exception('Không tìm thấy tài khoản để lấy profile. Yêu cầu đăng nhập.');
    }
  }
}
