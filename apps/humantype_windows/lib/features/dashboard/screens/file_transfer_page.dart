import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import '../../file_transfer/providers/active_transfers_provider.dart';
import '../../file_transfer/services/file_sender_service.dart';

class FileTransferPage extends ConsumerWidget {
  const FileTransferPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeTransfers = ref.watch(activeTransfersProvider);
    final theme = FluentTheme.of(context);

    return ScaffoldPage(
      header: PageHeader(
        title: const Text('File Transfer Center'),
        commandBar: CommandBar(
          mainAxisAlignment: MainAxisAlignment.end,
          primaryItems: [
            CommandBarButton(
              icon: const Icon(FluentIcons.add),
              label: const Text('Send File'),
              onPressed: () => _pickAndSendFile(ref),
            ),
            CommandBarButton(
              icon: const Icon(FluentIcons.fabric_folder),
              label: const Text('Remote Browser'),
              onPressed: () {
                // TODO: Launch remote file browser
              },
            ),
          ],
        ),
      ),
      content: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTransferStats(context),
            const SizedBox(height: 32),
            Text(
              activeTransfers.isEmpty ? 'Transfer History' : 'Active Transfers',
              style: theme.typography.subtitle?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: activeTransfers.isEmpty 
                ? _buildEmptyState(context, ref)
                : ListView.separated(
                    itemCount: activeTransfers.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final transfer = activeTransfers[index];
                      return _buildTransferCard(context, ref, transfer);
                    },
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickAndSendFile(WidgetRef ref) async {
    final result = await FilePicker.platform.pickFiles();
    if (result != null && result.files.single.path != null) {
      final path = result.files.single.path!;
      final sender = ref.read(fileSenderServiceProvider);
      
      sender.sendFile(path).listen((progress) {
        ref.read(activeTransfersProvider.notifier).updateProgress(progress);
      });
    }
  }

  Widget _buildEmptyState(BuildContext context, WidgetRef ref) {
    final theme = FluentTheme.of(context);
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(FluentIcons.open_file, size: 48, color: theme.typography.caption?.color?.withOpacity(0.1)),
            const SizedBox(height: 16),
            Text(
              'No active transfers',
              style: theme.typography.body?.copyWith(
                color: theme.typography.caption?.color?.withOpacity(0.5),
              ),
            ),
            const SizedBox(height: 8),
            Button(
              onPressed: () => _pickAndSendFile(ref),
              child: const Text('Select File to Send'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransferCard(BuildContext context, WidgetRef ref, TransferProgress transfer) {
    final theme = FluentTheme.of(context);
    final isError = transfer.status == TransferStatus.error;
    final isComplete = transfer.status == TransferStatus.complete;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isError ? Colors.red.withOpacity(0.3) : Colors.white.withOpacity(0.05),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    isComplete ? FluentIcons.check_mark : FluentIcons.sync,
                    size: 16,
                    color: isComplete ? Colors.green : theme.accentColor,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Transfer ID: ${transfer.transferId.substring(0, 8)}',
                    style: theme.typography.bodyStrong,
                  ),
                ],
              ),
              if (isComplete || isError)
                IconButton(
                  icon: const Icon(FluentIcons.clear, size: 12),
                  onPressed: () => ref.read(activeTransfersProvider.notifier).remove(transfer.transferId),
                ),
            ],
          ),
          const SizedBox(height: 12),
          ProgressBar(
            value: transfer.progressFraction * 100,
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                isError ? 'Error: ${transfer.error}' : '${(transfer.progressFraction * 100).toInt()}% uploaded',
                style: theme.typography.caption?.copyWith(
                  color: isError ? Colors.red : theme.typography.caption?.color?.withOpacity(0.6),
                ),
              ),
              Text(
                '${_formatSize(transfer.bytesSent)} / ${_formatSize(transfer.totalBytes)}',
                style: theme.typography.caption,
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  Widget _buildTransferStats(BuildContext context) {
    return Row(
      children: [
        _buildStatCard(context, 'SENT', '0', FluentIcons.upload, Colors.blue),
        const SizedBox(width: 16),
        _buildStatCard(context, 'RECEIVED', '0', FluentIcons.download, Colors.green),
        const SizedBox(width: 16),
        _buildStatCard(context, 'LIMIT', '2 GB', FluentIcons.database, Colors.purple),
      ],
    );
  }

  Widget _buildStatCard(BuildContext context, String label, String value, IconData icon, Color color) {
    final theme = FluentTheme.of(context);
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 16),
                const SizedBox(width: 8),
                Text(label, style: theme.typography.caption?.copyWith(fontWeight: FontWeight.bold, color: color)),
              ],
            ),
            const SizedBox(height: 8),
            Text(value, style: theme.typography.title?.copyWith(fontWeight: FontWeight.w900)),
          ],
        ),
      ),
    );
  }
}
