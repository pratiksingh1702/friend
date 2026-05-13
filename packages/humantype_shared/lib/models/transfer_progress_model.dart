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

  Map<String, dynamic> toJson() => {
    'transfer_id': transferId,
    'bytes_sent': bytesSent,
    'total_bytes': totalBytes,
    'progress_fraction': progressFraction,
    'status': status.name,
    'error': error,
  };
}
