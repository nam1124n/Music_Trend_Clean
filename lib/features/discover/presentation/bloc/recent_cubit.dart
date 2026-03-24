import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:login_flutter/features/admin/domain/entities/song_entity.dart';

class RecentCubit extends Cubit<List<SongEntity>> {
  RecentCubit() : super([]);

  void addRecent(SongEntity song) {
    final currentList = List<SongEntity>.from(state);

    // Remove if already exists so it can be moved to the top
    currentList.removeWhere((s) => s.id == song.id);

    // Insert at index 0 (top of the list)
    currentList.insert(0, song);

    emit(currentList);
  }
}
