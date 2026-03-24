import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:login_flutter/features/admin/domain/entities/song_entity.dart';

class FavoriteCubit extends Cubit<List<SongEntity>> {
  FavoriteCubit() : super([]);

  void toggleFavorite(SongEntity song) {
    final currentList = List<SongEntity>.from(state);
    final isFavorite = currentList.any((s) => s.id == song.id);

    if (isFavorite) {
      currentList.removeWhere((s) => s.id == song.id);
    } else {
      currentList.add(song);
    }

    emit(currentList);
  }

  bool isFavorite(String songId) {
    return state.any((s) => s.id == songId);
  }
}
