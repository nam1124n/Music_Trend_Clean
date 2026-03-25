import 'package:flutter/foundation.dart';

class AiConfig {
  static String get localBaseUrl {
    const configuredBaseUrl = String.fromEnvironment(
      'OLLAMA_LOCAL_BASE_URL',
      defaultValue: '',
    );
    if (configuredBaseUrl.isNotEmpty) {
      return configuredBaseUrl;
    }

    if (kIsWeb) {
      return 'http://127.0.0.1:11434/api';
    }

    return switch (defaultTargetPlatform) {
      TargetPlatform.android => 'http://10.0.2.2:11434/api',
      _ => 'http://127.0.0.1:11434/api',
    };
  }

  static String get cloudBaseUrl =>
      const String.fromEnvironment('OLLAMA_CLOUD_BASE_URL', defaultValue: '');

  static String get localModel => const String.fromEnvironment(
    'OLLAMA_LOCAL_MODEL',
    defaultValue: 'llama3:latest',
  );

  static String get cloudModel => const String.fromEnvironment(
    'OLLAMA_CLOUD_MODEL',
    defaultValue: 'gpt-oss:20b-cloud',
  );

  static int get timeoutSeconds =>
      const int.fromEnvironment('OLLAMA_TIMEOUT_SECONDS', defaultValue: 30);
}
