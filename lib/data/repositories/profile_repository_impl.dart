import 'package:login_flutter/domain/entities/profile_entity.dart';
import 'package:login_flutter/domain/repositories/profile_repository.dart';
import 'package:login_flutter/data/datasource/local/profile_local_data_source.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileLocalDataSource localDataSource;

  ProfileRepositoryImpl({required this.localDataSource});

  @override
  Future<ProfileEntity> getProfile() async {
    try {
      final profileModel = await localDataSource.getProfile();
      return profileModel;
    } catch (e) {
      throw Exception('Failed to get profile');
    }
  }
}
