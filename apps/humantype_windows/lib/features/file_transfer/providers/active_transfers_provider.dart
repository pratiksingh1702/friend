import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/file_sender_service.dart';

class ActiveTransfersNotifier extends StateNotifier<List<TransferProgress>> {
  ActiveTransfersNotifier() : super([]);

  void updateProgress(TransferProgress progress) {
    final index = state.indexWhere((p) => p.transferId == progress.transferId);
    if (index >= 0) {
      state = [
        ...state.sublist(0, index),
        progress,
        ...state.sublist(index + 1),
      ];
    } else {
      state = [progress, ...state];
    }
  }

  void remove(String transferId) {
    state = state.where((p) => p.transferId != transferId).toList();
  }
}

final activeTransfersProvider = StateNotifierProvider<ActiveTransfersNotifier, List<TransferProgress>>((ref) {
  return ActiveTransfersNotifier();
});
