import 'package:image_picker/image_picker.dart';

import '../entities/song_entity.dart';
import '../repositories/song_repository.dart';

class AddSongUseCase {
  final SongRepository repository;
  AddSongUseCase(this.repository);

  Future<void> call(SongEntity song, XFile imageFile, XFile audioFile) =>
      repository.addSong(song, imageFile, audioFile);
}
