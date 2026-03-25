import 'package:login_flutter/app/config/ai_config.dart';
import 'package:login_flutter/data/datasource/remote/ollama_ai_remote_data_source.dart';
import 'package:login_flutter/domain/entities/search_plan_entity.dart';
import 'package:login_flutter/domain/repositories/ai_search_repository.dart';

class AiSearchRepositoryImpl implements AiSearchRepository {
  final OllamaAiRemoteDataSource remoteDataSource;
  AiSearchRepositoryImpl(this.remoteDataSource);

  @override
  Future<SearchPlanEntity> analyzeQuery(String query) async {
    try {
      final data = await remoteDataSource.analyzeQuery(
        baseUrl: AiConfig.localBaseUrl,
        query: query,
        model: AiConfig.localModel,
      );
      return _map(query, data, 'local');
    } catch (_) {
      if (AiConfig.cloudBaseUrl.isNotEmpty) {
        try {
          final data = await remoteDataSource.analyzeQuery(
            baseUrl: AiConfig.cloudBaseUrl,
            query: query,
            model: AiConfig.cloudModel,
          );
          return _map(query, data, 'cloud');
        } catch (_) {}
      }

      return SearchPlanEntity(
        originalQuery: query,
        keywords: query.toLowerCase().split(' '),
        artistHints: const [],
        titleHints: const [],
        provider: 'rule',
        reason: 'Fallback search thuong',
      );
    }
  }

  SearchPlanEntity _map(
    String query,
    Map<String, dynamic> data,
    String provider,
  ) {
    List<String> readList(String key) => ((data[key] as List?) ?? [])
        .map((e) => e.toString().toLowerCase())
        .toList();

    return SearchPlanEntity(
      originalQuery: query,
      keywords: readList('keywords'),
      artistHints: readList('artistHints'),
      titleHints: readList('titleHints'),
      provider: provider,
      reason: data['reason']?.toString() ?? '',
    );
  }
}
