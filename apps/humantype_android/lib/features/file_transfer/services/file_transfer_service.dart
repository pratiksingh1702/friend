import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_filex/open_filex.dart';
import 'package:humantype_shared/humantype_shared.dart';
import '../../connect/services/wifi_service.dart';
import '../../../core/services/device_identity.dart';

class ActiveTransfer {
  final String transferId;
  final String fileName;
  final int totalBytes;
  int receivedBytes;
  final File file;
  final IOSink sink;

  ActiveTransfer({
    required this.transferId,
    required this.fileName,
    required this.totalBytes,
    required this.file,
    required this.sink,
    this.receivedBytes = 0,
  });
}

class FileTransferService {
  final WiFiService _wifiService;
  final Map<String, ActiveTransfer> _activeTransfers = {};
  StreamSubscription? _sub;

  FileTransferService(this._wifiService) {
    _sub = _wifiService.messages.listen(_onMessage);
  }

  void _onMessage(WsMessage msg) {
    if (msg.type == MessageType.fileTransferStart) {
      _handleTransferStart(msg.payload);
    } else if (msg.type == MessageType.fileTransferChunk) {
      _handleTransferChunk(msg.payload);
    } else if (msg.type == MessageType.fileTransferComplete) {
      _handleTransferComplete(msg.payload);
    }
  }

  Stream<double> sendFile(String filePath) async* {
    final file = File(filePath);
    if (!await file.exists()) return;

    final fileName = file.path.split('/').last;
    final fileSize = await file.length();
    final transferId = const Uuid().v4();
    const chunkSize = 65536;
    final totalChunks = (fileSize / chunkSize).ceil();

    // Start
    _wifiService.router.route(WsMessage(
      type: MessageType.fileTransferStart,
      sender: DeviceInfo.android(deviceId: await DeviceIdentityService().getDeviceId()),
      target: MessageTarget.broadcast,
      payload: {
        'transfer_id': transferId,
        'file_name': fileName,
        'file_size_bytes': fileSize,
        'total_chunks': totalChunks,
      },
    ));

    final raf = await file.open();
    int bytesSent = 0;

    try {
      for (int i = 0; i < totalChunks; i++) {
        final buffer = await raf.read(chunkSize);
        bytesSent += buffer.length;

        _wifiService.router.route(WsMessage(
          type: MessageType.fileTransferChunk,
          sender: DeviceInfo.android(deviceId: await DeviceIdentityService().getDeviceId()),
          target: MessageTarget.broadcast,
          payload: {
            'transfer_id': transferId,
            'chunk_index': i,
            'data_base64': base64Encode(buffer),
            'is_last': i == totalChunks - 1,
          },
        ));

        yield bytesSent / fileSize;
        await Future.delayed(const Duration(milliseconds: 10));
      }

      // Complete
      _wifiService.router.route(WsMessage(
        type: MessageType.fileTransferComplete,
        sender: DeviceInfo.android(deviceId: await DeviceIdentityService().getDeviceId()),
        target: MessageTarget.broadcast,
        payload: {
          'transfer_id': transferId,
          'file_name': fileName,
        },
      ));
    } finally {
      await raf.close();
    }
  }

  Future<void> _handleTransferStart(Map<String, dynamic> payload) async {
    final transferId = payload['transfer_id'] as String?;
    final fileName = payload['file_name'] as String?;
    final totalBytes = payload['file_size_bytes'] as int? ?? 0;

    if (transferId == null || fileName == null) return;

    try {
      final dir = await getExternalStorageDirectory() ?? await getApplicationDocumentsDirectory();
      final downloadsDir = Directory('${dir.path}/Downloads');
      if (!await downloadsDir.exists()) {
        await downloadsDir.create(recursive: true);
      }

      final file = File('${downloadsDir.path}/$fileName');
      var saveFile = file;
      int count = 1;
      while (await saveFile.exists()) {
        saveFile = File('${downloadsDir.path}/${count}_$fileName');
        count++;
      }

      final sink = saveFile.openWrite();
      _activeTransfers[transferId] = ActiveTransfer(
        transferId: transferId,
        fileName: fileName,
        totalBytes: totalBytes,
        file: saveFile,
        sink: sink,
      );

      print('[FileTransfer] Started receiving: $fileName');
    } catch (e) {
      print('[FileTransfer] Error starting: $e');
    }
  }

  Future<void> _handleTransferChunk(Map<String, dynamic> payload) async {
    final transferId = payload['transfer_id'] as String?;
    final dataBase64 = payload['data_base64'] as String?;

    if (transferId == null || dataBase64 == null) return;

    final transfer = _activeTransfers[transferId];
    if (transfer == null) return;

    try {
      final Uint8List data = base64Decode(dataBase64);
      transfer.sink.add(data);
      transfer.receivedBytes += data.length;
    } catch (e) {
      print('[FileTransfer] Error chunk: $e');
    }
  }

  Future<void> _handleTransferComplete(Map<String, dynamic> payload) async {
    final transferId = payload['transfer_id'] as String?;
    if (transferId == null) return;

    final transfer = _activeTransfers.remove(transferId);
    if (transfer == null) return;

    try {
      await transfer.sink.flush();
      await transfer.sink.close();
      
      print('[FileTransfer] Completed: ${transfer.fileName}');
      // Trigger notification or UI update
      _openFile(transfer.file.path);
    } catch (e) {
      print('[FileTransfer] Error completing: $e');
    }
  }

  void _openFile(String path) {
    OpenFilex.open(path);
  }

  void dispose() {
    _sub?.cancel();
    for (var t in _activeTransfers.values) {
      t.sink.close();
    }
  }
}

final fileTransferServiceProvider = Provider<FileTransferService>((ref) {
  final service = FileTransferService(ref.watch(wifiServiceProvider));
  ref.onDispose(service.dispose);
  return service;
});
