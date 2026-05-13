import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../sync/services/android_sync_service.dart';

enum TransferStatus { idle, sending, complete, error, cancelled }

class TransferProgress {
  final String transferId;
  final int bytesSent;
  final int totalBytes;
  final double progressFraction;
  final TransferStatus status;
  final String? error;

  const TransferProgress({
    required this.transferId,
    this.bytesSent = 0,
    this.totalBytes = 0,
    this.progressFraction = 0.0,
    this.status = TransferStatus.idle,
    this.error,
  });

  TransferProgress copyWith({
    int? bytesSent,
    int? totalBytes,
    double? progressFraction,
    TransferStatus? status,
    String? error,
  }) {
    return TransferProgress(
      transferId: transferId,
      bytesSent: bytesSent ?? this.bytesSent,
      totalBytes: totalBytes ?? this.totalBytes,
      progressFraction: progressFraction ?? this.progressFraction,
      status: status ?? this.status,
      error: error ?? this.error,
    );
  }
}

class FileSenderService {
  final AndroidSyncService _syncService;
  static const int _chunkSize = 65536; // 64KB

  FileSenderService(this._syncService);

  Stream<TransferProgress> sendFile(String filePath) async* {
    final file = File(filePath);
    if (!await file.exists()) {
      yield TransferProgress(
        transferId: 'error',
        status: TransferStatus.error,
        error: 'File does not exist',
      );
      return;
    }

    final fileName = file.path.split(Platform.pathSeparator).last;
    final fileSize = await file.length();
    final totalChunks = (fileSize / _chunkSize).ceil();
    final transferId = const Uuid().v4();

    yield TransferProgress(
      transferId: transferId,
      totalBytes: fileSize,
      status: TransferStatus.sending,
    );

    // 1. Send file_transfer_start
    _syncService.send({
      'type': 'file_transfer_start',
      'payload': {
        'transfer_id': transferId,
        'file_name': fileName,
        'file_size_bytes': fileSize,
        'total_chunks': totalChunks,
        'mime_type': 'application/octet-stream', // Could improve with mime package
      }
    });

    // 2. Read and send chunks
    final randomAccessFile = await file.open();
    int bytesSent = 0;

    try {
      for (int i = 0; i < totalChunks; i++) {
        final buffer = await randomAccessFile.read(_chunkSize);
        bytesSent += buffer.length;

        _syncService.send({
          'type': 'file_transfer_chunk',
          'payload': {
            'transfer_id': transferId,
            'chunk_index': i,
            'data_base64': base64Encode(buffer),
            'is_last': i == totalChunks - 1,
          }
        });

        yield TransferProgress(
          transferId: transferId,
          totalBytes: fileSize,
          bytesSent: bytesSent,
          progressFraction: bytesSent / fileSize,
          status: TransferStatus.sending,
        );
        
        // Small delay to prevent flooding
        await Future.delayed(const Duration(milliseconds: 10));
      }

      // 3. Send file_transfer_complete
      _syncService.send({
        'type': 'file_transfer_complete',
        'payload': {
          'transfer_id': transferId,
          'file_name': fileName,
          'checksum_md5': '', // Simplified for V1
        }
      });

      yield TransferProgress(
        transferId: transferId,
        totalBytes: fileSize,
        bytesSent: fileSize,
        progressFraction: 1.0,
        status: TransferStatus.complete,
      );

    } catch (e) {
      yield TransferProgress(
        transferId: transferId,
        status: TransferStatus.error,
        error: e.toString(),
      );
    } finally {
      await randomAccessFile.close();
    }
  }
}

final fileSenderServiceProvider = Provider<FileSenderService>((ref) {
  return FileSenderService(ref.watch(androidSyncServiceProvider));
});
