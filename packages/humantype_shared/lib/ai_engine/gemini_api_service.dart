import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/section_model.dart';
import '../models/ai_models.dart';
import 'ai_service.dart';

class GeminiApiService implements AiService {
  GeminiApiService({required this.apiKey, this.model = _defaultModel});

  static const _defaultModel = 'gemini-1.5-flash';
  static const _endpoint = 'https://generativelanguage.googleapis.com/v1beta/models';

  final String apiKey;
  final String model;

  @override
  String get name => 'Gemini';

  @override
  Future<List<Section>> parseInstructions(String input) async {
    final response = await http.post(
      Uri.parse('$_endpoint/$model:generateContent?key=$apiKey'),
      headers: {'content-type': 'application/json'},
      body: jsonEncode({
        'contents': [
          {
            'parts': [
              {
                'text': 'System: You are a typing session configurator. Return ONLY a JSON array of sections. \n\nUser: $input'
              }
            ]
          }
        ],
        'generationConfig': {
          'responseMimeType': 'application/json',
        }
      }),
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw StateError('Gemini API error: ${response.statusCode}\n${response.body}');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final candidates = data['candidates'] as List;
    final content = candidates.first['content'] as Map<String, dynamic>;
    final parts = content['parts'] as List;
    final text = parts.first['text'] as String? ?? '[]';
    
    final decoded = jsonDecode(text) as List;
    return decoded
        .map((item) => Section.fromJson((item as Map).cast<String, dynamic>()))
        .toList();
  }

  @override
  Future<String> processOcrResult(String ocrText, String userIntent) async {
    final response = await http.post(
      Uri.parse('$_endpoint/$model:generateContent?key=$apiKey'),
      headers: {'content-type': 'application/json'},
      body: jsonEncode({
        'contents': [
          {
            'parts': [
              {
                'text': 'System: You are an OCR assistant. Return only the processed answer text.\n\nIntent: $userIntent\n\nOCR Text:\n$ocrText'
              }
            ]
          }
        ]
      }),
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw StateError('Gemini API error: ${response.statusCode}');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final candidates = data['candidates'] as List;
    final content = candidates.first['content'] as Map<String, dynamic>;
    final parts = content['parts'] as List;
    return parts.first['text'] as String? ?? '';
  }

  Future<AiResponse> processRequest(AiRequest request) async {
    String systemPrompt = '';
    switch (request.task) {
      case AiTaskType.autocomplete:
        systemPrompt = 'You are a writing assistant. Continue the text naturally. Return 3 short suggestions.';
        break;
      case AiTaskType.rewrite:
        systemPrompt = 'Rewrite the following text to be more professional and clear.';
        break;
      case AiTaskType.improve:
        systemPrompt = 'Improve the grammar and flow of this text.';
        break;
      case AiTaskType.quickReply:
        systemPrompt = 'Generate 3 quick, natural replies to this message.';
        break;
      case AiTaskType.ocrAnalysis:
        systemPrompt = 'Analyze this OCR text and extract key information.';
        break;
    }

    final response = await http.post(
      Uri.parse('$_endpoint/$model:generateContent?key=$apiKey'),
      headers: {'content-type': 'application/json'},
      body: jsonEncode({
        'contents': [
          {
            'parts': [
              {
                'text': 'System: $systemPrompt\n\nInput: ${request.text}'
              }
            ]
          }
        ],
        'generationConfig': {
          if (request.task == AiTaskType.autocomplete || request.task == AiTaskType.quickReply)
            'responseMimeType': 'application/json',
        }
      }),
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw StateError('Gemini API error: ${response.statusCode}');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final candidates = data['candidates'] as List;
    final content = candidates.first['content'] as Map<String, dynamic>;
    final parts = content['parts'] as List;
    final resultText = parts.first['text'] as String? ?? '';

    if (request.task == AiTaskType.autocomplete || request.task == AiTaskType.quickReply) {
      try {
        final decoded = jsonDecode(resultText);
        if (decoded is List) {
          return AiResponse(suggestions: decoded.cast<String>());
        } else if (decoded is Map && decoded.containsKey('suggestions')) {
          return AiResponse(suggestions: (decoded['suggestions'] as List).cast<String>());
        }
      } catch (_) {}
    }

    return AiResponse(suggestions: [], result: resultText);
  }
}
