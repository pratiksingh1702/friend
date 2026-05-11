import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:humantype_shared/humantype_shared.dart';

class ConnectionState {
  const ConnectionState({
    required this.isConnected,
    required this.quality,
    required this.method,
    this.device,
  });

  final bool isConnected;
  final ConnectedDevice? device;
  final ConnectionQuality quality;
  final ConnectionMethod method;

  factory ConnectionState.disconnected() {
    return const ConnectionState(
      isConnected: false,
      quality: ConnectionQuality.disconnected,
      method: ConnectionMethod.none,
    );
  }

  ConnectionState copyWith({
    bool? isConnected,
    ConnectedDevice? device,
    ConnectionQuality? quality,
    ConnectionMethod? method,
  }) {
    return ConnectionState(
      isConnected: isConnected ?? this.isConnected,
      device: device ?? this.device,
      quality: quality ?? this.quality,
      method: method ?? this.method,
    );
  }
}

class ConnectionNotifier extends Notifier<ConnectionState> {
  @override
  ConnectionState build() => ConnectionState.disconnected();

  void setConnected(
    ConnectedDevice device, {
    ConnectionQuality quality = ConnectionQuality.good,
    ConnectionMethod method = ConnectionMethod.wifi,
  }) {
    state = state.copyWith(
      isConnected: true,
      device: device,
      quality: quality,
      method: method,
    );
  }

  void setQuality(ConnectionQuality quality) {
    state = state.copyWith(quality: quality);
  }

  void setDisconnected() {
    state = ConnectionState.disconnected();
  }
}

final connectionProvider =
    NotifierProvider<ConnectionNotifier, ConnectionState>(
  ConnectionNotifier.new,
);
