import '../entities/song_entity.dart';
import '../repositories/song_repository.dart';

class AddSongUseCase {
  final SongRepository repository;
  AddSongUseCase(this.repository);

  Future<void> call(
    SongEntity song,
    String localImagePath,
    String localAudioPath,
  ) =>
      repository.addSong(song, localImagePath, localAudioPath);
}
