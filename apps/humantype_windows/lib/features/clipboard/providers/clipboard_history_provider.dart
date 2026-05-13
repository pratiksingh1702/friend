import 'package:flutter_riverpod/flutter_riverpod.dart';

class ClipboardItem {
  final String content;
  final DateTime timestamp;
  final bool isFromRemote;

  ClipboardItem({
    required this.content,
    required this.timestamp,
    required this.isFromRemote,
  });
}

class ClipboardHistoryNotifier extends StateNotifier<List<ClipboardItem>> {
  ClipboardHistoryNotifier() : super([]);

  void addItem(String content, bool isFromRemote) {
    if (state.isNotEmpty && state.first.content == content) return;
    
    state = [
      ClipboardItem(
        content: content,
        timestamp: DateTime.now(),
        isFromRemote: isFromRemote,
      ),
      ...state,
    ].take(30).toList();
  }

  void clear() => state = [];
}

final clipboardHistoryProvider = StateNotifierProvider<ClipboardHistoryNotifier, List<ClipboardItem>>((ref) {
  return ClipboardHistoryNotifier();
});
