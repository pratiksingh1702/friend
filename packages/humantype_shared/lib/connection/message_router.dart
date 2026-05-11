import '../protocols/message_types.dart';
import '../protocols/ws_message.dart';

typedef MessageHandler = Future<void> Function(WsMessage message);

class MessageRouter {
  final Map<MessageType, List<MessageHandler>> _handlers = {};

  void register(MessageType type, MessageHandler handler) {
    _handlers.putIfAbsent(type, () => <MessageHandler>[]).add(handler);
  }

  Future<void> route(WsMessage message) async {
    final handlers = _handlers[message.type];
    if (handlers == null || handlers.isEmpty) {
      return;
    }
    for (final handler in handlers) {
      await handler(message);
    }
  }
}
