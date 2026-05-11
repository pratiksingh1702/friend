import 'dart:convert';

import 'package:http/http.dart' as http;

import 'ai_service.dart';
import '../models/section_model.dart';

class ClaudeApiService implements AiService {
  ClaudeApiService({required this.apiKey, this.model = _defaultModel});

  @override
  String get name => 'Claude';

  static const _defaultModel = 'claude-sonnet-4-20250514';
  static const _endpoint = 'https://api.anthropic.com/v1/messages';

  final String apiKey;
  final String model;

  Future<List<Section>> parseInstructions(String input) async {
    final response = await http.post(
      Uri.parse(_endpoint),
      headers: {
        'x-api-key': apiKey,
        'anthropic-version': '2023-06-01',
        'content-type': 'application/json',
      },
      body: jsonEncode({
        'model': model,
        'max_tokens': 1000,
        'system':
            'You are a typing session configurator. Return JSON for sections.',
        'messages': [
          {
            'role': 'user',
            'content': input,
          }
        ],
      }),
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw StateError('Claude API error: ${response.statusCode}');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final content = (data['content'] as List).first as Map<String, dynamic>;
    final text = content['text'] as String? ?? '[]';
    final decoded = jsonDecode(text) as List;
    return decoded
        .map((item) => Section.fromJson((item as Map).cast<String, dynamic>()))
        .toList();
  }

  Future<String> processOcrResult(String ocrText, String userIntent) async {
    final response = await http.post(
      Uri.parse(_endpoint),
      headers: {
        'x-api-key': apiKey,
        'anthropic-version': '2023-06-01',
        'content-type': 'application/json',
      },
      body: jsonEncode({
        'model': model,
        'max_tokens': 800,
        'system':
            'You are an OCR assistant. Return only the processed answer text.',
        'messages': [
          {
            'role': 'user',
            'content':
                'Intent: $userIntent\n\nOCR Text:\n$ocrText',
          }
        ],
      }),
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw StateError('Claude API error: ${response.statusCode}');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final content = (data['content'] as List).first as Map<String, dynamic>;
    return content['text'] as String? ?? '';
  }
}
