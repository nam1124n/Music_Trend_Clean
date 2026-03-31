import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:login_flutter/domain/entities/song_entity.dart';

final recentNotifierProvider =
    StateNotifierProvider<RecentNotifier, List<SongEntity>>((ref) {
      return RecentNotifier();
    });

class RecentNotifier extends StateNotifier<List<SongEntity>> {
  RecentNotifier() : super([]);

  void addRecent(SongEntity song) {
    final currentList = List<SongEntity>.from(state);

    // Remove if already exists so it can be moved to the top
    currentList.removeWhere((s) => s.id == song.id);

    // Insert at index 0 (top of the list)
    currentList.insert(0, song);

    state = currentList;
  }
}
