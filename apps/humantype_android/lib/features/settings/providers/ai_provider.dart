import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:humantype_shared/humantype_shared.dart';

import 'settings_provider.dart';

final aiServiceProvider = Provider<AiService?>((ref) {
  final settings = ref.watch(settingsProvider);
  if (!settings.aiEnabled) return null;

  switch (settings.selectedAiProvider) {
    case AiProvider.gemini:
      if (settings.geminiApiKey.isEmpty) return null;
      return GeminiApiService(apiKey: settings.geminiApiKey);
    case AiProvider.claude:
      if (settings.claudeApiKey.isEmpty) return null;
      return ClaudeApiService(apiKey: settings.claudeApiKey);
    case AiProvider.openai:
      // OpenAI implementation can be added here
      return null;
  }
});
