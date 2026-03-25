import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:login_flutter/domain/entities/song_entity.dart';
import 'package:login_flutter/domain/usecases/analyze_search_query_usecase.dart';
import 'package:login_flutter/ui/screen/search/cubit/search_state.dart';

class SearchCubit extends Cubit<SearchState> {
  final AnalyzeSearchQueryUseCase analyzeSearchQueryUseCase;

  SearchCubit({required this.analyzeSearchQueryUseCase})
    : super(SearchInitial());

  Future<void> search({
    required String query,
    required List<SongEntity> songs,
  }) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) {
      emit(SearchInitial());
      return;
    }

    emit(SearchLoading());

    try {
      final plan = await analyzeSearchQueryUseCase(trimmed);
      final results = _rankSongs(
        songs: songs,
        query: trimmed,
        tokens: [...plan.keywords, ...plan.artistHints, ...plan.titleHints],
      );

      emit(SearchLoaded(results: results, plan: plan));
    } catch (e) {
      emit(SearchError(e.toString()));
    }
  }

  List<SongEntity> _rankSongs({
    required List<SongEntity> songs,
    required String query,
    required List<String> tokens,
  }) {
    final normalizedQuery = query.toLowerCase();
    final uniqueTokens = {
      ...normalizedQuery.split(RegExp(r'\s+')).where((e) => e.isNotEmpty),
      ...tokens.where((e) => e.isNotEmpty),
    }.toList();

    final scored = <MapEntry<SongEntity, int>>[];

    for (final song in songs) {
      final title = song.title.toLowerCase();
      final artist = song.artist.toLowerCase();
      var score = 0;

      if (title.contains(normalizedQuery)) score += 8;
      if (artist.contains(normalizedQuery)) score += 10;

      for (final token in uniqueTokens) {
        if (title.contains(token)) score += 3;
        if (artist.contains(token)) score += 4;
      }

      if (score > 0) {
        scored.add(MapEntry(song, score));
      }
    }

    scored.sort((a, b) => b.value.compareTo(a.value));
    return scored.map((entry) => entry.key).toList();
  }
}
