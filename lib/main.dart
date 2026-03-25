// main.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:login_flutter/firebase_options.dart';

// Auth
import 'package:login_flutter/ui/screen/auth/bloc/auth_bloc.dart';
import 'package:login_flutter/domain/usecases/login_usecase.dart';
import 'package:login_flutter/domain/usecases/signup_usecase.dart';
import 'package:login_flutter/data/repositories/auth_repository_impl.dart';
import 'package:login_flutter/data/datasource/remote/auth_remote_data_source.dart';
import 'package:login_flutter/ui/screen/auth/login_screen.dart';

// Admin - Song
import 'package:login_flutter/data/datasource/remote/song_remote_data_source.dart';
import 'package:login_flutter/data/repositories/song_repository_impl.dart';
import 'package:login_flutter/domain/usecases/get_songs_usecase.dart';
import 'package:login_flutter/domain/usecases/add_song_usecase.dart';
import 'package:login_flutter/domain/usecases/delete_song_usecase.dart';
import 'package:login_flutter/domain/usecases/get_weekly_trending_songs_usecase.dart';
import 'package:login_flutter/domain/usecases/track_song_listen_usecase.dart';
import 'package:login_flutter/ui/screen/admin/bloc/song_bloc.dart';
import 'package:login_flutter/ui/screen/audio/cubit/audio_player_cubit.dart';
import 'package:login_flutter/ui/screen/discover/bloc/favorite_cubit.dart';
import 'package:login_flutter/ui/screen/discover/bloc/recent_cubit.dart';
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // ── Auth DI ──
  final authDataSource = AuthRemoteDataSourceImpl();
  final authRepository = AuthRepositoryImpl(authDataSource);
  final loginUseCase   = LoginUseCase(authRepository);
  final signUpUseCase  = SignUpUseCase(authRepository);

  // ── Song DI ──
  final songDataSource    = SongRemoteDataSource();
  final songRepository    = SongRepositoryImpl(songDataSource);
  final getSongsUseCase   = GetSongsUseCase(songRepository);
  final addSongUseCase    = AddSongUseCase(songRepository);
  final deleteSongUseCase = DeleteSongUseCase(songRepository);
  final getWeeklyTrendingSongsUseCase =
      GetWeeklyTrendingSongsUseCase(songRepository);
  final trackSongListenUseCase = TrackSongListenUseCase(songRepository);

  runApp(
    MultiRepositoryProvider(
      providers: [
        RepositoryProvider<GetWeeklyTrendingSongsUseCase>.value(
          value: getWeeklyTrendingSongsUseCase,
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<AuthBloc>(
            create: (_) => AuthBloc(
              loginUseCase: loginUseCase,
              signUpUseCase: signUpUseCase,
            ),
          ),
          BlocProvider<SongBloc>(
            create: (_) => SongBloc(
              getSongsUseCase: getSongsUseCase,
              addSongUseCase: addSongUseCase,
              deleteSongUseCase: deleteSongUseCase,
            ),
          ),
          BlocProvider<AudioPlayerCubit>(
            create: (_) => AudioPlayerCubit(
              trackSongListenUseCase: trackSongListenUseCase,
            ),
          ),
          BlocProvider<FavoriteCubit>(
            create: (_) => FavoriteCubit(),
          ),
          BlocProvider<RecentCubit>(
            create: (_) => RecentCubit(),
          ),
        ],
        child: const MaterialApp(
          home: SafeArea(
            child: Scaffold(body: LoginScreen()),
          ),
          debugShowCheckedModeBanner: false,
        ),
      ),
    ),
  );
}
