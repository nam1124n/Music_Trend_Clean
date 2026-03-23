import 'package:equatable/equatable.dart';
import 'package:login_flutter/features/admin/domain/entities/song_entity.dart';

class AudioPlayerState extends Equatable {
  final SongEntity? currentSong;
  final bool isPlaying;
  final bool isLoading;
  final bool isError;
  final Duration position;
  final Duration duration;
  final List<SongEntity> playlist;

  const AudioPlayerState({
    this.currentSong,
    this.isPlaying = false,
    this.isLoading = false,
    this.isError = false,
    this.position = Duration.zero,
    this.duration = Duration.zero,
    this.playlist = const [],
  });

  AudioPlayerState copyWith({
    SongEntity? currentSong,
    bool? isPlaying,
    bool? isLoading,
    bool? isError,
    Duration? position,
    Duration? duration,
    List<SongEntity>? playlist,
  }) {
    return AudioPlayerState(
      currentSong: currentSong ?? this.currentSong,
      isPlaying: isPlaying ?? this.isPlaying,
      isLoading: isLoading ?? this.isLoading,
      isError: isError ?? this.isError,
      position: position ?? this.position,
      duration: duration ?? this.duration,
      playlist: playlist ?? this.playlist,
    );
  }

  @override
  List<Object?> get props => [
        currentSong,
        isPlaying,
        isLoading,
        isError,
        position,
        duration,
        playlist,
      ];
}
