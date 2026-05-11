import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:humantype_shared/humantype_shared.dart';

import '../../../core/services/local_store.dart';

final historyProvider =
    AsyncNotifierProvider<HistoryNotifier, List<SessionModel>>(
  HistoryNotifier.new,
);

class HistoryNotifier extends AsyncNotifier<List<SessionModel>> {
  @override
  Future<List<SessionModel>> build() async {
    return _loadHistory();
  }

  Future<List<SessionModel>> _loadHistory() async {
    final box = LocalStore.instance.historyBox;
    return box.values
        .map((value) => SessionModel.fromJson(value.cast<String, dynamic>()))
        .toList();
  }

  Future<void> addSession(SessionModel session) async {
    final box = LocalStore.instance.historyBox;
    await box.put(session.id, session.toJson());
    final current = state.value ?? const <SessionModel>[];
    state = AsyncData([...current, session]);
  }

  Future<void> clearHistory() async {
    final box = LocalStore.instance.historyBox;
    await box.clear();
    state = const AsyncData([]);
  }
}
