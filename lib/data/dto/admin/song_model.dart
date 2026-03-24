import 'package:login_flutter/domain/entities/song_entity.dart';

class SongModel extends SongEntity {
  const SongModel({
    required super.id,
    required super.title,
    required super.artist,
    required super.audioUrl,
    required super.imageUrl,
  });

  factory SongModel.fromFirestore(Map<String, dynamic> map, String id) {
    return SongModel(
      id: id,
      title: map['title'] ?? '',
      artist: map['artist'] ?? '',
      audioUrl: map['audioUrl'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
    );
  }

  Map<String, dynamic> toMap() => {
        'title': title,
        'artist': artist,
        'audioUrl': audioUrl,
        'imageUrl': imageUrl,
      };

  factory SongModel.fromEntity(SongEntity entity) => SongModel(
        id: entity.id,
        title: entity.title,
        artist: entity.artist,
        audioUrl: entity.audioUrl,
        imageUrl: entity.imageUrl,
      );
}
