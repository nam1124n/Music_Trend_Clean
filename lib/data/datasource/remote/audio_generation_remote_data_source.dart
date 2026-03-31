import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:login_flutter/app/config/audio_generation_config.dart';
import 'package:login_flutter/data/dto/audio_generation/generated_audio_model.dart';

class AudioGenerationRemoteDataSource {
  static const String _mockSampleAudioUrl =
      'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3';

  Future<GeneratedAudioModel> generateAudio({
    required String baseUrl,
    required String prompt,
    required int durationSeconds,
  }) async {
    if (baseUrl.startsWith('mock://')) {
      return _generateMockAudio(
        prompt: prompt,
        durationSeconds: durationSeconds,
      );
    }

    final normalizedBaseUrl = baseUrl.replaceFirst(RegExp(r'/+$'), '');
    final response = await http
        .post(
          Uri.parse('$normalizedBaseUrl${AudioGenerationConfig.generatePath}'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'prompt': prompt,
            'duration_seconds': durationSeconds,
            'format': 'mp3',
          }),
        )
        .timeout(Duration(seconds: AudioGenerationConfig.timeoutSeconds));

    if (response.statusCode >= 400) {
      throw Exception(
        'Không thể tạo audio (${response.statusCode}): ${response.body}',
      );
    }

    final decoded = jsonDecode(response.body);
    final payload = decoded is Map<String, dynamic>
        ? (decoded['data'] is Map<String, dynamic>
              ? decoded['data'] as Map<String, dynamic>
              : decoded)
        : <String, dynamic>{};

    return GeneratedAudioModel.fromJson(payload);
  }

  Future<GeneratedAudioModel> _generateMockAudio({
    required String prompt,
    required int durationSeconds,
  }) async {
    await Future<void>.delayed(const Duration(seconds: 2));

    return GeneratedAudioModel(
      id: 'mock_${DateTime.now().millisecondsSinceEpoch}',
      title: _buildTitle(prompt),
      prompt: prompt,
      audioUrl: _mockSampleAudioUrl,
      imageUrl: '',
      durationSeconds: durationSeconds,
      provider: 'mock-suno-api',
    );
  }

  String _buildTitle(String prompt) {
    final words = prompt
        .trim()
        .split(RegExp(r'\s+'))
        .where((word) => word.isNotEmpty)
        .take(4)
        .map(_capitalize)
        .toList();

    if (words.isEmpty) {
      return 'AI Audio Demo';
    }

    return words.join(' ');
  }

  String _capitalize(String value) {
    if (value.isEmpty) {
      return value;
    }

    return '${value[0].toUpperCase()}${value.substring(1)}';
  }
}
