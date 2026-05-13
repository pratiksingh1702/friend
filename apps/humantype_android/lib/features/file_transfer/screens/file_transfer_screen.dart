import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import '../../../core/theme.dart';
import '../../../core/widgets/human_type_scaffold.dart';
import '../services/file_transfer_service.dart';

class FileTransferScreen extends ConsumerStatefulWidget {
  const FileTransferScreen({super.key});

  @override
  ConsumerState<FileTransferScreen> createState() => _FileTransferScreenState();
}

class _FileTransferScreenState extends ConsumerState<FileTransferScreen> {
  PlatformFile? _selectedFile;
  bool _isSending = false;
  double _progress = 0;

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles();
    if (result != null) {
      setState(() {
        _selectedFile = result.files.single;
      });
    }
  }

  void _sendFile() {
    if (_selectedFile == null || _selectedFile!.path == null) return;
    
    setState(() {
      _isSending = true;
      _progress = 0;
    });

    final service = ref.read(fileTransferServiceProvider);
    service.sendFile(_selectedFile!.path!).listen(
      (p) => setState(() => _progress = p),
      onDone: () {
        setState(() {
          _isSending = false;
          _selectedFile = null;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('File sent successfully!')),
        );
      },
      onError: (e) {
        setState(() => _isSending = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    );
  }

  @override
  Widget build(BuildContext context) {
    return HumanTypeScaffold(
      title: 'File Transfer',
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_selectedFile == null) ...[
              const Icon(Icons.upload_file, size: 64, color: Colors.white24),
              const SizedBox(height: 24),
              Text('No file selected', style: HumanTypeText.heading2),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _pickFile,
                child: const Text('Pick File'),
              ),
            ] else ...[
              _buildFileCard(),
              const SizedBox(height: 32),
              if (!_isSending)
                ElevatedButton(
                  onPressed: _sendFile,
                  child: const Text('Send to Laptop'),
                )
              else ...[
                LinearProgressIndicator(value: _progress),
                const SizedBox(height: 16),
                Text('${(_progress * 100).toInt()}%', style: HumanTypeText.body),
              ],
              const SizedBox(height: 16),
              TextButton(
                onPressed: _isSending ? null : () => setState(() => _selectedFile = null),
                child: const Text('Cancel'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildFileCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: HumanTypeColors.bgElevated,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: HumanTypeColors.borderSubtle),
      ),
      child: Column(
        children: [
          const Icon(Icons.description, size: 48, color: Colors.white),
          const SizedBox(height: 16),
          Text(_selectedFile!.name, style: HumanTypeText.heading2, textAlign: TextAlign.center),
          const SizedBox(height: 8),
          Text(_formatSize(_selectedFile!.size), style: HumanTypeText.bodySmall),
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
