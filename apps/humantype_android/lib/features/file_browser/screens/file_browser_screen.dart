import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:humantype_shared/humantype_shared.dart';
import '../../../core/theme.dart';
import '../../../core/widgets/human_type_scaffold.dart';
import '../../connect/services/wifi_service.dart';
import '../../../core/services/device_identity.dart';

class FileBrowserScreen extends ConsumerStatefulWidget {
  const FileBrowserScreen({super.key});

  @override
  ConsumerState<FileBrowserScreen> createState() => _FileBrowserScreenState();
}

class _FileBrowserScreenState extends ConsumerState<FileBrowserScreen> {
  String _currentPath = '';
  List<RemoteFileInfo> _files = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _requestFiles('');
    
    // Register response handler
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(wifiServiceProvider).router.register(MessageType.fileBrowseResponse, (msg) async {
        if (!mounted) return;
        final payload = msg.payload;
        if (payload['error'] != null) {
          setState(() {
            _error = payload['error'];
            _isLoading = false;
          });
        } else {
          setState(() {
            _currentPath = payload['path'];
            _files = (payload['files'] as List)
                .map((f) => RemoteFileInfo.fromJson(f))
                .toList();
            _isLoading = false;
            _error = null;
          });
        }
      });
    });
  }

  Future<void> _requestFiles(String path) async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    final wifi = ref.read(wifiServiceProvider);
    if (!wifi.isConnected) {
      setState(() {
        _error = 'Not connected to laptop';
        _isLoading = false;
      });
      return;
    }

    final deviceId = await DeviceIdentityService().getDeviceId();
    wifi.router.route(WsMessage(
      type: MessageType.fileBrowseRequest,
      sender: DeviceInfo.android(deviceId: deviceId),
      target: MessageTarget.broadcast,
      payload: {
        'request_id': 'browser-${DateTime.now().millisecondsSinceEpoch}',
        'path': path,
      },
    ));
  }

  @override
  Widget build(BuildContext context) {
    return HumanTypeScaffold(
      title: 'Browse Laptop',
      actions: [
        IconButton(
          onPressed: () => _requestFiles(_currentPath),
          icon: const Icon(Icons.refresh),
        ),
      ],
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : _error != null
          ? Center(child: Text(_error!, style: HumanTypeText.body))
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(_currentPath, style: HumanTypeText.caption),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: _files.length,
                    itemBuilder: (context, index) {
                      final file = _files[index];
                      return ListTile(
                        leading: Icon(
                          file.isDirectory ? Icons.folder : Icons.description,
                          color: file.isDirectory ? HumanTypeColors.accentPrimary : Colors.white70,
                        ),
                        title: Text(file.name, style: HumanTypeText.body),
                        subtitle: file.isDirectory ? null : Text(_formatSize(file.sizeBytes ?? 0)),
                        onTap: () {
                          if (file.isDirectory) {
                            _requestFiles(file.path);
                          } else {
                            _showFileOptions(file);
                          }
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }

  void _showFileOptions(RemoteFileInfo file) {
    showModalBottomSheet(
      context: context,
      backgroundColor: HumanTypeColors.bgElevated,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.download),
            title: const Text('Download to Phone'),
            onTap: () {
              // Trigger download logic
              Navigator.pop(context);
            },
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  String _formatSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}
