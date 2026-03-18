import '../entities/song_entity.dart';

abstract class SongRepository {
  Stream<List<SongEntity>> getSongs();
  Future<void> addSong(
    SongEntity song,
    String localImagePath,
    String localAudioPath,
  );
  Future<void> deleteSong(String id);
}
