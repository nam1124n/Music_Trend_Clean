import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:just_audio/just_audio.dart';
import 'package:login_flutter/domain/entities/song_entity.dart';
import 'package:login_flutter/domain/usecases/track_song_listen_usecase.dart';
import 'package:login_flutter/ui/screen/audio/cubit/audio_player_state.dart';

class AudioPlayerCubit extends Cubit<AudioPlayerState> {
  static const Duration _defaultListenThreshold = Duration(seconds: 30);

  final AudioPlayer _audioPlayer;
  final TrackSongListenUseCase _trackSongListenUseCase;
  bool _hasTrackedCurrentPlayback = false;

  AudioPlayerCubit({
    required TrackSongListenUseCase trackSongListenUseCase,
  })
      : _audioPlayer = AudioPlayer(),
        _trackSongListenUseCase = trackSongListenUseCase,
        super(const AudioPlayerState()) {
    _initStreams();
  }

  void _initStreams() {
    _audioPlayer.playerStateStream.listen((playerState) {
      final isPlaying = playerState.playing;
      final processingState = playerState.processingState;

      if (processingState == ProcessingState.completed) {
        // Auto play next song if possible
        if (state.playlist.isNotEmpty && state.currentIndex < state.playlist.length - 1) {
          next();
        } else {
          emit(state.copyWith(isPlaying: false, position: Duration.zero));
          _audioPlayer.seek(Duration.zero);
          _audioPlayer.pause();
        }
      } else {
        emit(state.copyWith(
          isPlaying: isPlaying,
          isLoading: processingState == ProcessingState.loading || processingState == ProcessingState.buffering,
        ));
      }
    });

    _audioPlayer.positionStream.listen((position) {
      emit(state.copyWith(position: position));
      unawaited(_trackListenIfNeeded(position));
    });

    _audioPlayer.durationStream.listen((duration) {
      emit(state.copyWith(duration: duration ?? Duration.zero));
    });
  }

  Future<void> playSong(SongEntity song, {List<SongEntity>? playlist}) async {
    try {
      final currentPlaylist = playlist ?? state.playlist;
      final index = currentPlaylist.indexWhere((s) => s.id == song.id);
      _hasTrackedCurrentPlayback = false;

      emit(state.copyWith(
        currentSong: song,
        playlist: currentPlaylist,
        currentIndex: index != -1 ? index : 0,
        isLoading: true,
        isError: false,
      ));

      await _audioPlayer.setUrl(song.audioUrl);
      _audioPlayer.play();
    } catch (e) {
      emit(state.copyWith(isError: true, isLoading: false));
    }
  }

  void pause() {
    _audioPlayer.pause();
  }

  void resume() {
    _audioPlayer.play();
  }

  void seek(Duration position) {
    _audioPlayer.seek(position);
  }

  Future<void> next() async {
    if (state.playlist.isEmpty) return;
    
    final nextIndex = state.currentIndex + 1;
    if (nextIndex < state.playlist.length) {
      final nextSong = state.playlist[nextIndex];
      await playSong(nextSong, playlist: state.playlist);
    }
  }

  Future<void> previous() async {
    if (state.playlist.isEmpty) return;

    if (state.position.inSeconds > 3) {
      // If played more than 3 seconds, previous goes to start of current song
      await _audioPlayer.seek(Duration.zero);
    } else {
      final prevIndex = state.currentIndex - 1;
      if (prevIndex >= 0) {
        final prevSong = state.playlist[prevIndex];
        await playSong(prevSong, playlist: state.playlist);
      } else {
        await _audioPlayer.seek(Duration.zero);
      }
    }
  }

  Future<void> _trackListenIfNeeded(Duration position) async {
    if (_hasTrackedCurrentPlayback) {
      return;
    }

    final song = state.currentSong;
    if (song == null) {
      return;
    }

    final threshold = _listenThresholdFor(state.duration);
    if (position < threshold) {
      return;
    }

    _hasTrackedCurrentPlayback = true;

    try {
      await _trackSongListenUseCase(song);
    } catch (_) {
      _hasTrackedCurrentPlayback = false;
    }
  }

  Duration _listenThresholdFor(Duration duration) {
    if (duration == Duration.zero || duration >= _defaultListenThreshold) {
      return _defaultListenThreshold;
    }

    return Duration(
      milliseconds: (duration.inMilliseconds * 0.6).round(),
    );
  }

  @override
  Future<void> close() {
    _audioPlayer.dispose();
    return super.close();
  }
}
