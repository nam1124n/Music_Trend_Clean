// main.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

// Auth
import 'package:login_flutter/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:login_flutter/features/auth/domain/usecases/login_usecase.dart';
import 'package:login_flutter/features/auth/domain/usecases/signup_usecase.dart';
import 'package:login_flutter/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:login_flutter/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:login_flutter/features/auth/presentation/page/page_login.dart';

// Admin - Song
import 'package:login_flutter/features/admin/data/datasources/song_remote_data_source.dart';
import 'package:login_flutter/features/admin/data/repositories/song_repository_impl.dart';
import 'package:login_flutter/features/admin/domain/usecase/get_songs_usecase.dart';
import 'package:login_flutter/features/admin/domain/usecase/add_song_usecase.dart';
import 'package:login_flutter/features/admin/domain/usecase/delete_song_usecase.dart';
import 'package:login_flutter/features/admin/presentation/bloc/song_bloc.dart';
import 'package:login_flutter/features/audio/presentation/cubit/audio_player_cubit.dart';

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

  runApp(
    MultiBlocProvider(
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
          create: (_) => AudioPlayerCubit(),
        ),
      ],
      child: const MaterialApp(
        home: SafeArea(
          child: Scaffold(body: LoginWidget()),
        ),
        debugShowCheckedModeBanner: false,
      ),
    ),
  );
}
