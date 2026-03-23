import 'package:image_picker/image_picker.dart';

import '../entities/song_entity.dart';

abstract class SongRepository {
  Stream<List<SongEntity>> getSongs();
  Future<void> addSong(SongEntity song, XFile imageFile, XFile audioFile);
  Future<void> deleteSong(String id);
}
