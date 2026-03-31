import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:login_flutter/domain/entities/song_entity.dart';

final favoriteNotifierProvider =
    StateNotifierProvider<FavoriteNotifier, List<SongEntity>>((ref) {
      return FavoriteNotifier();
    });

class FavoriteNotifier extends StateNotifier<List<SongEntity>> {
  FavoriteNotifier() : super([]);

  void toggleFavorite(SongEntity song) {
    final currentList = List<SongEntity>.from(state);
    final isFavorite = currentList.any((s) => s.id == song.id);

    if (isFavorite) {
      currentList.removeWhere((s) => s.id == song.id);
    } else {
      currentList.add(song);
    }

    state = currentList;
  }

  bool isFavorite(String songId) {
    return state.any((s) => s.id == songId);
  }
}
