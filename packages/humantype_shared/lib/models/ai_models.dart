enum AiTaskType {
  autocomplete,
  rewrite,
  improve,
  quickReply,
  ocrAnalysis,
}

class AiRequest {
  final String text;
  final AiTaskType task;
  final Map<String, dynamic> context;

  AiRequest({
    required this.text,
    required this.task,
    this.context = const {},
  });

  Map<String, dynamic> toJson() => {
        'text': text,
        'task': task.name,
        'context': context,
      };

  factory AiRequest.fromJson(Map<String, dynamic> json) => AiRequest(
        text: json['text'] as String,
        task: AiTaskType.values.firstWhere(
          (e) => e.name == json['task'],
          orElse: () => AiTaskType.autocomplete,
        ),
        context: (json['context'] as Map?)?.cast<String, dynamic>() ?? {},
      );
}

class AiResponse {
  final List<String> suggestions;
  final String? result;
  final double confidence;

  AiResponse({
    required this.suggestions,
    this.result,
    this.confidence = 1.0,
  });

  Map<String, dynamic> toJson() => {
        'suggestions': suggestions,
        'result': result,
        'confidence': confidence,
      };

  factory AiResponse.fromJson(Map<String, dynamic> json) => AiResponse(
        suggestions: (json['suggestions'] as List?)?.cast<String>() ?? [],
        result: json['result'] as String?,
        confidence: (json['confidence'] as num?)?.toDouble() ?? 1.0,
      );
}
