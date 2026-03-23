import 'package:image_picker/image_picker.dart';
import 'package:login_flutter/features/admin/domain/entities/song_entity.dart';
import 'package:login_flutter/features/admin/domain/repositories/song_repository.dart';
import 'package:login_flutter/features/admin/data/datasources/song_remote_data_source.dart';
import 'package:login_flutter/features/admin/data/models/song_model.dart';

class SongRepositoryImpl implements SongRepository {
  final SongRemoteDataSource remoteDataSource;
  SongRepositoryImpl(this.remoteDataSource);

  @override
  Stream<List<SongEntity>> getSongs() {
    return remoteDataSource.getSongsStream().map((snapshot) {
      return snapshot.docs.map((doc) {
        return SongModel.fromFirestore(
          doc.data() as Map<String, dynamic>,
          doc.id,
        );
      }).toList();
    });
  }

  @override
  Future<void> addSong(
    SongEntity song,
    XFile imageFile,
    XFile audioFile,
  ) async {
    final results = await Future.wait([
      remoteDataSource.uploadImage(imageFile),
      remoteDataSource.uploadAudio(audioFile),
    ]);
    final imageUrl = results[0];
    final audioUrl = results[1];

    final model = SongModel.fromEntity(song);
    await remoteDataSource.addSong({
      ...model.toMap(),
      'imageUrl': imageUrl,
      'audioUrl': audioUrl,
    });
  }

  @override
  Future<void> deleteSong(String id) async {
    await remoteDataSource.deleteSong(id);
  }
}
