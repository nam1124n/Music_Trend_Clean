import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:login_flutter/data/datasource/remote/audio_generation_remote_data_source.dart';
import 'package:login_flutter/data/repositories/audio_generation_repository_impl.dart';
import 'package:login_flutter/domain/repositories/audio_generation_repository.dart';
import 'package:login_flutter/domain/usecases/generate_audio_usecase.dart';
import 'package:login_flutter/ui/screen/create_audio/providers/create_audio_state.dart';

final audioGenerationRemoteDataSourceProvider =
    Provider<AudioGenerationRemoteDataSource>((ref) {
      return AudioGenerationRemoteDataSource();
    });

final audioGenerationRepositoryProvider = Provider<AudioGenerationRepository>((
  ref,
) {
  return AudioGenerationRepositoryImpl(
    ref.read(audioGenerationRemoteDataSourceProvider),
  );
});

final generateAudioUseCaseProvider = Provider<GenerateAudioUseCase>((ref) {
  return GenerateAudioUseCase(ref.read(audioGenerationRepositoryProvider));
});

final createAudioNotifierProvider =
    StateNotifierProvider.autoDispose<CreateAudioNotifier, CreateAudioState>((
      ref,
    ) {
      return CreateAudioNotifier(ref.read(generateAudioUseCaseProvider));
    });

class CreateAudioNotifier extends StateNotifier<CreateAudioState> {
  final GenerateAudioUseCase generateAudioUseCase;

  CreateAudioNotifier(this.generateAudioUseCase)
    : super(const CreateAudioState());

  void onPromptChanged(String value) {
    state = state.copyWith(
      prompt: value,
      status: CreateAudioStatus.initial,
      errorMessage: null,
    );
  }

  void onDurationChanged(int value) {
    state = state.copyWith(
      durationSeconds: value,
      status: CreateAudioStatus.initial,
      errorMessage: null,
    );
  }

  Future<void> generateAudio({
    required String promptRequiredMessage,
    required String promptTooShortMessage,
    required String audioDurationRangeMessage,
  }) async {
    final prompt = state.prompt.trim();

    if (prompt.isEmpty) {
      state = state.copyWith(
        status: CreateAudioStatus.error,
        errorMessage: promptRequiredMessage,
        clearGeneratedAudio: true,
      );
      return;
    }

    if (prompt.length < 10) {
      state = state.copyWith(
        status: CreateAudioStatus.error,
        errorMessage: promptTooShortMessage,
        clearGeneratedAudio: true,
      );
      return;
    }

    if (state.durationSeconds < 5 || state.durationSeconds > 60) {
      state = state.copyWith(
        status: CreateAudioStatus.error,
        errorMessage: audioDurationRangeMessage,
        clearGeneratedAudio: true,
      );
      return;
    }

    state = state.copyWith(
      status: CreateAudioStatus.loading,
      errorMessage: null,
      clearGeneratedAudio: true,
    );

    try {
      final generatedAudio = await generateAudioUseCase(
        prompt: prompt,
        durationSeconds: state.durationSeconds,
      );
      state = state.copyWith(
        status: CreateAudioStatus.success,
        generatedAudio: generatedAudio,
        errorMessage: null,
      );
    } catch (e) {
      state = state.copyWith(
        status: CreateAudioStatus.error,
        errorMessage: e.toString().replaceFirst('Exception: ', ''),
        clearGeneratedAudio: true,
      );
    }
  }
}
