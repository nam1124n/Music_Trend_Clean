import 'package:login_flutter/domain/entities/search_plan_entity.dart';
import 'package:login_flutter/domain/entities/song_entity.dart';

abstract class SearchState {}

class SearchInitial extends SearchState {}

class SearchLoading extends SearchState {}

class SearchLoaded extends SearchState {
  final List<SongEntity> results;
  final SearchPlanEntity plan;

  SearchLoaded({required this.results, required this.plan});
}

class SearchError extends SearchState {
  final String message;

  SearchError(this.message);
}
