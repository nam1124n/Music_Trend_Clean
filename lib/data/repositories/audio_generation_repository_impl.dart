import 'package:login_flutter/app/config/audio_generation_config.dart';
import 'package:login_flutter/data/datasource/remote/audio_generation_remote_data_source.dart';
import 'package:login_flutter/domain/entities/generated_audio_entity.dart';
import 'package:login_flutter/domain/repositories/audio_generation_repository.dart';

class AudioGenerationRepositoryImpl implements AudioGenerationRepository {
  final AudioGenerationRemoteDataSource remoteDataSource;
  final String baseUrl;

  AudioGenerationRepositoryImpl(this.remoteDataSource, {String? baseUrl})
    : baseUrl = baseUrl ?? AudioGenerationConfig.baseUrl;

  @override
  Future<GeneratedAudioEntity> generateAudio({
    required String prompt,
    required int durationSeconds,
  }) {
    return remoteDataSource.generateAudio(
      baseUrl: baseUrl,
      prompt: prompt,
      durationSeconds: durationSeconds,
    );
  }
}
