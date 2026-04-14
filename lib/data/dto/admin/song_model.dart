import 'package:login_flutter/domain/entities/song_entity.dart';

class SongModel extends SongEntity {
  const SongModel({
    required super.id,
    required super.title,
    required super.artist,
    required super.audioUrl,
    required super.imageUrl,
    super.semanticTags = const [],
    super.searchAliases = const [],
    super.energyLevel = 3,
  });

  factory SongModel.fromFirestore(Map<String, dynamic> map, String id) {
    return SongModel.fromEntity(SongEntity.fromJson({...map, 'id': id}));
  }

  Map<String, dynamic> toMap() => {
    'title': title,
    'artist': artist,
    'audioUrl': audioUrl,
    'imageUrl': imageUrl,
    'semanticTags': semanticTags,
    'searchAliases': searchAliases,
    'energyLevel': energyLevel,
  };

  factory SongModel.fromEntity(SongEntity entity) => SongModel(
    id: entity.id,
    title: entity.title,
    artist: entity.artist,
    audioUrl: entity.audioUrl,
    imageUrl: entity.imageUrl,
    semanticTags: entity.semanticTags,
    searchAliases: entity.searchAliases,
    energyLevel: entity.energyLevel,
  );
}
