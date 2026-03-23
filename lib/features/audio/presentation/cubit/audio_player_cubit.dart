import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:just_audio/just_audio.dart';
import 'package:login_flutter/features/admin/domain/entities/song_entity.dart';
import 'audio_player_state.dart';

class AudioPlayerCubit extends Cubit<AudioPlayerState> {
  final AudioPlayer _audioPlayer;

  AudioPlayerCubit()
      : _audioPlayer = AudioPlayer(),
        super(const AudioPlayerState()) {
    _initStreams();
  }

  void _initStreams() {
    _audioPlayer.playerStateStream.listen((playerState) {
      final isPlaying = playerState.playing;
      final processingState = playerState.processingState;

      if (processingState == ProcessingState.completed) {
        emit(state.copyWith(isPlaying: false, position: Duration.zero));
        _audioPlayer.seek(Duration.zero);
        _audioPlayer.pause();
      } else {
        emit(state.copyWith(
          isPlaying: isPlaying,
          isLoading: processingState == ProcessingState.loading || processingState == ProcessingState.buffering,
        ));
      }
    });

    _audioPlayer.positionStream.listen((position) {
      emit(state.copyWith(position: position));
    });

    _audioPlayer.durationStream.listen((duration) {
      emit(state.copyWith(duration: duration ?? Duration.zero));
    });
  }

  Future<void> playSong(SongEntity song, {List<SongEntity>? playlist}) async {
    try {
      emit(state.copyWith(
        currentSong: song,
        playlist: playlist ?? state.playlist,
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

  @override
  Future<void> close() {
    _audioPlayer.dispose();
    return super.close();
  }
}
