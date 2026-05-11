import 'dart:convert';
import 'package:http/http.dart' as http;

import 'ai_service.dart';
import '../models/section_model.dart';
import '../models/ai_models.dart';

class ClaudeApiService implements AiService {
  ClaudeApiService({required this.apiKey, this.model = _defaultModel});

  @override
  String get name => 'Claude';

  static const _defaultModel = 'claude-sonnet-4-20250514';
  static const _endpoint = 'https://api.anthropic.com/v1/messages';

  final String apiKey;
  final String model;

  @override
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

  @override
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

  @override
  Future<AiResponse> processRequest(AiRequest request) async {
    String systemPrompt = '';
    switch (request.task) {
      case AiTaskType.autocomplete:
        systemPrompt = 'You are a writing assistant. Continue the text naturally. Return 3 short suggestions as a JSON array of strings.';
        break;
      case AiTaskType.rewrite:
        systemPrompt = 'Rewrite the following text to be more professional and clear. Return only the text.';
        break;
      case AiTaskType.improve:
        systemPrompt = 'Improve the grammar and flow of this text. Return only the text.';
        break;
      case AiTaskType.quickReply:
        systemPrompt = 'Generate 3 quick, natural replies to this message. Return a JSON array of strings.';
        break;
      case AiTaskType.ocrAnalysis:
        systemPrompt = 'Analyze this OCR text and extract key information.';
        break;
    }

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
        'system': systemPrompt,
        'messages': [
          {
            'role': 'user',
            'content': request.text,
          }
        ],
      }),
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw StateError('Claude API error: ${response.statusCode}');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final content = (data['content'] as List).first as Map<String, dynamic>;
    final resultText = content['text'] as String? ?? '';

    if (request.task == AiTaskType.autocomplete || request.task == AiTaskType.quickReply) {
      try {
        final decoded = jsonDecode(resultText);
        if (decoded is List) {
          return AiResponse(suggestions: decoded.cast<String>());
        }
      } catch (_) {}
    }

    return AiResponse(suggestions: [], result: resultText);
  }
}
