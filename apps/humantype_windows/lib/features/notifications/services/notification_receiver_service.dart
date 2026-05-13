import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:local_notifier/local_notifier.dart';
import '../../sync/services/android_sync_service.dart';
import 'package:humantype_shared/protocols/message_types.dart';
import '../providers/notification_history_provider.dart';

class NotificationReceiverService {
  final Ref _ref;
  final AndroidSyncService _syncService;
  StreamSubscription? _sub;

  NotificationReceiverService(this._ref, this._syncService) {
    _sub = _syncService.messageStream.listen(_onMessage);
  }

  Future<void> init() async {
    await localNotifier.setup(
      appName: 'HumanType',
    );
  }

  void _onMessage(Map<String, dynamic> msg) {
    final type = msg['type'] as String?;
    if (type == MessageType.notificationMirror.wireName) {
      final payload = msg['payload'] as Map<String, dynamic>?;
      final title = payload?['title'] as String? ?? 'Phone Notification';
      final body = payload?['body'] as String? ?? '';
      final appName = payload?['app_name'] as String? ?? 'Android';

      _ref.read(notificationHistoryProvider.notifier).addNotification(appName, title, body);
      _showNotification(appName, title, body);
    }
  }

  void _showNotification(String appName, String title, String body) {
    LocalNotification notification = LocalNotification(
      title: '$appName: $title',
      body: body,
      silent: false,
    );
    
    notification.onShow = () {
      print('onShow ${notification.identifier}');
    };
    notification.onClose = (closeReason) {
      print('onClose ${notification.identifier} - $closeReason');
    };
    notification.onClick = () {
      print('onClick ${notification.identifier}');
    };

    notification.show();
  }

  void dispose() {
    _sub?.cancel();
  }
}

final notificationReceiverServiceProvider = Provider<NotificationReceiverService>((ref) {
  final service = NotificationReceiverService(ref, ref.watch(androidSyncServiceProvider));
  ref.onDispose(service.dispose);
  return service;
});
