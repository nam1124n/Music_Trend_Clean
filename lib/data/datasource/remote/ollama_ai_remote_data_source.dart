import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:login_flutter/app/config/ai_config.dart';

class OllamaAiRemoteDataSource {
  Future<Map<String, dynamic>> analyzeQuery({
    required String baseUrl,
    required String query,
    required String model,
  }) async {
    final schema = {
      'type': 'object',
      'properties': {
        'keywords': {
          'type': 'array',
          'items': {'type': 'string'},
        },
        'artistHints': {
          'type': 'array',
          'items': {'type': 'string'},
        },
        'titleHints': {
          'type': 'array',
          'items': {'type': 'string'},
        },
        'reason': {'type': 'string'},
      },
      'required': ['keywords', 'artistHints', 'titleHints', 'reason'],
    };

    final response = await http
        .post(
          Uri.parse('$baseUrl/chat'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'model': model,
            'stream': false,
            'format': schema,
            'options': {'temperature': 0},
            'messages': [
              {
                'role': 'system',
                'content':
                    'Ban la bo phan phan tich truy van tim nhac. Chi tra JSON hop le.',
              },
              {
                'role': 'user',
                'content':
                    'Phan tich cau tim kiem nay: "$query". Tach ra keywords, artistHints, titleHints, reason.',
              },
            ],
          }),
        )
        .timeout(Duration(seconds: AiConfig.timeoutSeconds));

    if (response.statusCode >= 400) {
      throw Exception('Ollama request failed: ${response.statusCode}');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final content = (data['message']?['content'] as String? ?? '')
        .replaceAll('```json', '')
        .replaceAll('```', '')
        .trim();

    if (content.isEmpty) {
      throw Exception('AI tra ve rong');
    }

    return jsonDecode(content) as Map<String, dynamic>;
  }
}
