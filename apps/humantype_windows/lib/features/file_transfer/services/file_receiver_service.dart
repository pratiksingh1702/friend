import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import '../../sync/services/android_sync_service.dart';
import 'package:humantype_shared/protocols/message_types.dart';
import 'package:local_notifier/local_notifier.dart';

class ActiveDownload {
  final String transferId;
  final String fileName;
  final int totalBytes;
  int receivedBytes;
  final File file;
  final IOSink sink;

  ActiveDownload({
    required this.transferId,
    required this.fileName,
    required this.totalBytes,
    required this.file,
    required this.sink,
    this.receivedBytes = 0,
  });
}

class FileReceiverService {
  final AndroidSyncService _syncService;
  final Map<String, ActiveDownload> _activeDownloads = {};
  StreamSubscription? _sub;

  FileReceiverService(this._syncService) {
    _sub = _syncService.messageStream.listen(_onMessage);
  }

  void _onMessage(Map<String, dynamic> msg) {
    final type = msg['type'] as String?;
    final payload = msg['payload'] as Map<String, dynamic>?;

    if (type == MessageType.fileTransferStart.wireName) {
      _handleTransferStart(payload);
    } else if (type == MessageType.fileTransferChunk.wireName) {
      _handleTransferChunk(payload);
    } else if (type == MessageType.fileTransferComplete.wireName) {
      _handleTransferComplete(payload);
    }
  }

  Future<void> _handleTransferStart(Map<String, dynamic>? payload) async {
    if (payload == null) return;
    
    final transferId = payload['transfer_id'] as String?;
    final fileName = payload['file_name'] as String?;
    final totalBytes = payload['file_size_bytes'] as int? ?? 0;

    if (transferId == null || fileName == null) return;

    try {
      final downloadsDir = await getDownloadsDirectory();
      if (downloadsDir == null) throw Exception('Could not access downloads directory');

      final file = File('${downloadsDir.path}${Platform.pathSeparator}$fileName');
      // If file exists, add a number
      var saveFile = file;
      int count = 1;
      while (await saveFile.exists()) {
        saveFile = File('${downloadsDir.path}${Platform.pathSeparator}$count\_$fileName');
        count++;
      }

      final sink = saveFile.openWrite();
      _activeDownloads[transferId] = ActiveDownload(
        transferId: transferId,
        fileName: fileName,
        totalBytes: totalBytes,
        file: saveFile,
        sink: sink,
      );

      print('[Receiver] Started receiving file: $fileName ($transferId)');
    } catch (e) {
      print('[Receiver] Error starting transfer: $e');
    }
  }

  Future<void> _handleTransferChunk(Map<String, dynamic>? payload) async {
    if (payload == null) return;
    
    final transferId = payload['transfer_id'] as String?;
    final dataBase64 = payload['data_base64'] as String?;

    if (transferId == null || dataBase64 == null) return;

    final download = _activeDownloads[transferId];
    if (download == null) return;

    try {
      final Uint8List data = base64Decode(dataBase64);
      download.sink.add(data);
      download.receivedBytes += data.length;
    } catch (e) {
      print('[Receiver] Error receiving chunk for $transferId: $e');
    }
  }

  Future<void> _handleTransferComplete(Map<String, dynamic>? payload) async {
    if (payload == null) return;
    
    final transferId = payload['transfer_id'] as String?;
    if (transferId == null) return;

    final download = _activeDownloads.remove(transferId);
    if (download == null) return;

    try {
      await download.sink.flush();
      await download.sink.close();
      
      print('[Receiver] Successfully received file: ${download.fileName}');
      
      _showSuccessNotification(download.fileName, download.file.path);
    } catch (e) {
      print('[Receiver] Error completing transfer: $e');
    }
  }

  void _showSuccessNotification(String fileName, String filePath) {
    LocalNotification notification = LocalNotification(
      title: 'File Received',
      body: '$fileName has been saved to your Downloads folder.',
      silent: false,
    );
    
    notification.onClick = () {
      // Open the file or folder
      Process.run('explorer.exe', ['/select,', filePath]);
    };

    notification.show();
  }

  void dispose() {
    _sub?.cancel();
    for (var download in _activeDownloads.values) {
      download.sink.close();
    }
  }
}

final fileReceiverServiceProvider = Provider<FileReceiverService>((ref) {
  final service = FileReceiverService(ref.watch(androidSyncServiceProvider));
  ref.onDispose(service.dispose);
  return service;
});
