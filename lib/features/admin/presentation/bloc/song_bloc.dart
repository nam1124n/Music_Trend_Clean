import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:login_flutter/features/admin/domain/usecase/get_songs_usecase.dart';
import 'package:login_flutter/features/admin/domain/usecase/add_song_usecase.dart';
import 'package:login_flutter/features/admin/domain/usecase/delete_song_usecase.dart';
import 'song_event.dart';
import 'song_state.dart';

class SongBloc extends Bloc<SongEvent, SongState> {
  final GetSongsUseCase getSongsUseCase;
  final AddSongUseCase addSongUseCase;
  final DeleteSongUseCase deleteSongUseCase;

  SongBloc({
    required this.getSongsUseCase,
    required this.addSongUseCase,
    required this.deleteSongUseCase,
  }) : super(SongInitial()) {
    on<LoadSongsEvent>(_onLoad);
    on<AddSongEvent>(_onAdd);
    on<DeleteSongEvent>(_onDelete);
  }

  Future<void> _onLoad(LoadSongsEvent event, Emitter<SongState> emit) async {
    emit(SongLoading());
    await emit.forEach(
      getSongsUseCase(),
      onData: (songs) => SongLoaded(songs),
      onError: (e, _) => SongError(e.toString()),
    );
  }

  Future<void> _onAdd(AddSongEvent event, Emitter<SongState> emit) async {
    emit(SongLoading());
    try {
      await addSongUseCase(event.song, event.localImagePath, event.localAudioPath);
      emit(SongActionSuccess());
    } catch (e) {
      emit(SongError(e.toString()));
    }
  }

  Future<void> _onDelete(DeleteSongEvent event, Emitter<SongState> emit) async {
    try {
      await deleteSongUseCase(event.id);
      emit(SongActionSuccess());
    } catch (e) {
      emit(SongError(e.toString()));
    }
  }
}
