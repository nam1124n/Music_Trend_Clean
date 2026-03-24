import 'package:image_picker/image_picker.dart';
import 'package:login_flutter/domain/entities/song_entity.dart';

abstract class SongEvent {}

class LoadSongsEvent extends SongEvent {}

class AddSongEvent extends SongEvent {
  final SongEntity song;
  final XFile imageFile;
  final XFile audioFile;
  AddSongEvent(this.song, this.imageFile, this.audioFile);
}

class DeleteSongEvent extends SongEvent {
  final String id;
  DeleteSongEvent(this.id);
}
