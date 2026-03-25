class AiConfig {
  static const localBaseUrl = String.fromEnvironment(
    'OLLAMA_LOCAL_BASE_URL',
    defaultValue: 'http://10.0.2.2:11434/api',
  );

  static const cloudBaseUrl = String.fromEnvironment(
    'OLLAMA_CLOUD_BASE_URL',
    defaultValue: '',
  );

  static const localModel = String.fromEnvironment(
    'OLLAMA_LOCAL_MODEL',
    defaultValue: 'gemma3',
  );

  static const cloudModel = String.fromEnvironment(
    'OLLAMA_CLOUD_MODEL',
    defaultValue: 'gpt-oss:20b-cloud',
  );

  static const timeoutSeconds = int.fromEnvironment(
    'OLLAMA_TIMEOUT_SECONDS',
    defaultValue: 8,
  );
}
