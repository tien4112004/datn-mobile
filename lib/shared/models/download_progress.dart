/// Model for tracking download progress
class DownloadProgress {
  final int received;
  final int total;
  final String? filePath;

  DownloadProgress({
    required this.received,
    required this.total,
    this.filePath,
  });

  /// Calculate progress percentage (0.0 - 1.0)
  double get percentage => total > 0 ? (received / total) : 0;

  @override
  String toString() =>
      'DownloadProgress(received: $received, total: $total, percentage: ${(percentage * 100).toStringAsFixed(2)}%, filePath: $filePath)';
}
