import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:login_flutter/data/datasource/remote/ollama_ai_remote_data_source.dart';
import 'package:login_flutter/data/repositories/ai_search_repository_impl.dart';
import 'package:login_flutter/domain/entities/song_entity.dart';
import 'package:login_flutter/domain/repositories/ai_search_repository.dart';
import 'package:login_flutter/domain/usecases/analyze_search_query_usecase.dart';
import 'package:login_flutter/ui/screen/search/providers/search_state.dart';

final ollamaAiRemoteDataSourceProvider = Provider<OllamaAiRemoteDataSource>((
  ref,
) {
  return OllamaAiRemoteDataSource();
});

final aiSearchRepositoryProvider = Provider<AiSearchRepository>((ref) {
  return AiSearchRepositoryImpl(ref.read(ollamaAiRemoteDataSourceProvider));
});

final analyzeSearchQueryUseCaseProvider = Provider<AnalyzeSearchQueryUseCase>((
  ref,
) {
  return AnalyzeSearchQueryUseCase(ref.read(aiSearchRepositoryProvider));
});

final searchNotifierProvider =
    StateNotifierProvider<SearchNotifier, SearchState>((ref) {
      return SearchNotifier(
        analyzeSearchQueryUseCase: ref.read(analyzeSearchQueryUseCaseProvider),
      );
    });

class SearchNotifier extends StateNotifier<SearchState> {
  final AnalyzeSearchQueryUseCase analyzeSearchQueryUseCase;

  SearchNotifier({required this.analyzeSearchQueryUseCase})
    : super(SearchInitial());

  Future<void> search({
    required String query,
    required List<SongEntity> songs,
  }) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) {
      state = SearchInitial();
      return;
    }

    state = SearchLoading();

    try {
      final plan = await analyzeSearchQueryUseCase(trimmed);
      final results = _rankSongs(
        songs: songs,
        query: trimmed,
        tokens: [...plan.keywords, ...plan.artistHints, ...plan.titleHints],
      );

      state = SearchLoaded(results: results, plan: plan);
    } catch (e) {
      state = SearchError(e.toString());
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
