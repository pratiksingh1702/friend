import 'package:flutter_riverpod/flutter_riverpod.dart';

class MirroredNotification {
  final String id;
  final String packageName;
  final String title;
  final String body;
  final DateTime timestamp;

  MirroredNotification({
    required this.id,
    required this.packageName,
    required this.title,
    required this.body,
    required this.timestamp,
  });
}

class NotificationHistoryNotifier extends StateNotifier<List<MirroredNotification>> {
  NotificationHistoryNotifier() : super([]);

  void addNotification(String packageName, String title, String body) {
    state = [
      MirroredNotification(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        packageName: packageName,
        title: title,
        body: body,
        timestamp: DateTime.now(),
      ),
      ...state,
    ].take(50).toList(); // Keep last 50
  }

  void clear() => state = [];
}

final notificationHistoryProvider = StateNotifierProvider<NotificationHistoryNotifier, List<MirroredNotification>>((ref) {
  return NotificationHistoryNotifier();
});
