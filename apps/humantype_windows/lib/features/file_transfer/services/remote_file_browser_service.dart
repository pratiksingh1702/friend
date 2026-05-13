import 'dart:async';
import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import '../../sync/services/android_sync_service.dart';
import 'package:humantype_shared/protocols/message_types.dart';

class RemoteFileBrowserService {
  final AndroidSyncService _syncService;
  StreamSubscription? _sub;

  RemoteFileBrowserService(this._syncService) {
    _sub = _syncService.messageStream.listen(_onMessage);
  }

  void _onMessage(Map<String, dynamic> msg) {
    final type = msg['type'] as String?;
    if (type == MessageType.fileBrowseRequest.wireName) {
      final payload = msg['payload'] as Map<String, dynamic>?;
      final path = payload?['path'] as String? ?? '';
      
      _handleBrowseRequest(path);
    }
  }

  Future<void> _handleBrowseRequest(String requestedPath) async {
    try {
      String actualPath = requestedPath;
      
      // Handle special root paths
      if (requestedPath.isEmpty || requestedPath == '/') {
        await _sendRoots();
        return;
      }

      final dir = Directory(actualPath);
      if (!await dir.exists()) {
        _syncService.send({
          'type': 'file_browse_response',
          'payload': {
            'path': requestedPath,
            'error': 'Directory not found',
            'items': [],
          }
        });
        return;
      }

      final List<FileSystemEntity> entities = await dir.list().toList();
      final List<Map<String, dynamic>> items = [];

      for (var entity in entities) {
        final stat = await entity.stat();
        items.add({
          'name': entity.path.split(Platform.pathSeparator).last,
          'path': entity.path,
          'is_directory': entity is Directory,
          'size_bytes': stat.size,
          'last_modified_ms': stat.modified.millisecondsSinceEpoch,
        });
      }

      _syncService.send({
        'type': 'file_browse_response',
        'payload': {
          'path': requestedPath,
          'items': items,
        }
      });
    } catch (e) {
      _syncService.send({
        'type': 'file_browse_response',
        'payload': {
          'path': requestedPath,
          'error': e.toString(),
          'items': [],
        }
      });
    }
  }

  Future<void> _sendRoots() async {
    final List<Map<String, dynamic>> roots = [];
    
    // Add common Windows directories
    final documents = await getApplicationDocumentsDirectory();
    final downloads = await getDownloadsDirectory();
    final desktop = await getApplicationSupportDirectory(); // path_provider is limited on windows desktop
    
    // For V1, we'll just list the drive roots if possible or standard folders
    roots.add({
      'name': 'Documents',
      'path': documents.path,
      'is_directory': true,
      'size_bytes': 0,
      'last_modified_ms': DateTime.now().millisecondsSinceEpoch,
    });
    
    if (downloads != null) {
      roots.add({
        'name': 'Downloads',
        'path': downloads.path,
        'is_directory': true,
        'size_bytes': 0,
        'last_modified_ms': DateTime.now().millisecondsSinceEpoch,
      });
    }

    _syncService.send({
      'type': 'file_browse_response',
      'payload': {
        'path': '/',
        'items': roots,
      }
    });
  }

  void dispose() {
    _sub?.cancel();
  }
}

final remoteFileBrowserServiceProvider = Provider<RemoteFileBrowserService>((ref) {
  final service = RemoteFileBrowserService(ref.watch(androidSyncServiceProvider));
  ref.onDispose(service.dispose);
  return service;
});
