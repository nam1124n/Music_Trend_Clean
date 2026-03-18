import 'package:login_flutter/features/admin/domain/entities/song_entity.dart';

abstract class SongEvent {}

class LoadSongsEvent extends SongEvent {}

class AddSongEvent extends SongEvent {
  final SongEntity song;
  final String localImagePath;
  final String localAudioPath;
  AddSongEvent(this.song, this.localImagePath, this.localAudioPath);
}

class DeleteSongEvent extends SongEvent {
  final String id;
  DeleteSongEvent(this.id);
}
