import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:login_flutter/domain/entities/song_entity.dart';
import 'package:login_flutter/ui/screen/auth/providers/auth_provider.dart';
import 'package:login_flutter/ui/screen/auth/providers/auth_state.dart';
import 'package:shared_preferences/shared_preferences.dart';

final recentNotifierProvider =
    StateNotifierProvider<RecentNotifier, List<SongEntity>>((ref) {
      final authState = ref.watch(authNotifierProvider);
      final userId = authState is AuthSuccess ? authState.user.id : 'guest';
      return RecentNotifier(userId);
    });

class RecentNotifier extends StateNotifier<List<SongEntity>> {
  final String userId;

  RecentNotifier(this.userId) : super([]) {
    _loadRecents();
  }

  String get _key => 'recent_songs_$userId';

  Future<void> _loadRecents() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = prefs.getStringList(_key);
    if (jsonList != null && jsonList.isNotEmpty) {
      try {
        final loaded = jsonList
            .map((str) => SongEntity.fromJson(jsonDecode(str)))
            .toList();
        state = loaded;
      } catch (_) {}
    }
  }

  Future<void> _saveRecents(List<SongEntity> songs) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = songs.map((s) => jsonEncode(s.toJson())).toList();
    await prefs.setStringList(_key, jsonList);
  }

  void addRecent(SongEntity song) {
    final currentList = List<SongEntity>.from(state);

    // Remove if already exists so it can be moved to the top
    currentList.removeWhere((s) => s.id == song.id);

    // Insert at index 0 (top of the list)
    currentList.insert(0, song);

    // Keep only last 20 recents, optional limitation to avoid giant string
    if (currentList.length > 20) {
      currentList.removeLast();
    }

    state = currentList;
    _saveRecents(currentList);
  }
}
