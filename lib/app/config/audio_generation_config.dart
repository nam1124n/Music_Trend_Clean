class AudioGenerationConfig {
  static const String baseUrl = String.fromEnvironment(
    'AUDIO_GENERATION_BASE_URL',
    defaultValue: 'mock://audio-generator',
  );

  static const String generatePath = String.fromEnvironment(
    'AUDIO_GENERATION_GENERATE_PATH',
    defaultValue: '/v1/audio/generate',
  );

  static const int timeoutSeconds = int.fromEnvironment(
    'AUDIO_GENERATION_TIMEOUT_SECONDS',
    defaultValue: 45,
  );
}
