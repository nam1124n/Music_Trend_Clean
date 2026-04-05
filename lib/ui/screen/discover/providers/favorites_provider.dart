import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:login_flutter/domain/entities/song_entity.dart';
import 'package:login_flutter/ui/screen/auth/providers/auth_provider.dart';
import 'package:login_flutter/ui/screen/auth/providers/auth_state.dart';
import 'package:shared_preferences/shared_preferences.dart';

final favoriteNotifierProvider =
    StateNotifierProvider<FavoriteNotifier, List<SongEntity>>((ref) {
      final authState = ref.watch(authNotifierProvider);
      final userId = authState is AuthSuccess ? authState.user.id : 'guest';
      return FavoriteNotifier(userId);
    });

class FavoriteNotifier extends StateNotifier<List<SongEntity>> {
  final String userId;

  FavoriteNotifier(this.userId) : super([]) {
    _loadFavorites();
  }

  String get _key => 'favorites_songs_$userId';

  Future<void> _loadFavorites() async {
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

  Future<void> _saveFavorites(List<SongEntity> songs) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = songs.map((s) => jsonEncode(s.toJson())).toList();
    await prefs.setStringList(_key, jsonList);
  }

  void toggleFavorite(SongEntity song) {
    final currentList = List<SongEntity>.from(state);
    final isFavorite = currentList.any((s) => s.id == song.id);

    if (isFavorite) {
      currentList.removeWhere((s) => s.id == song.id);
    } else {
      currentList.add(song);
    }

    state = currentList;
    _saveFavorites(currentList);
  }

  bool isFavorite(String songId) {
    return state.any((s) => s.id == songId);
  }
}
