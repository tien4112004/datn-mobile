import 'package:datn_mobile/shared/services/download/models/download_progress.dart';

/// Abstract interface for download service
/// Handles downloading files with progress tracking
abstract interface class DownloadService {
  /// Download image from URL and save to device gallery
  ///
  /// Parameters:
  /// - [url]: URL of the image to download
  /// - [prompt]: Prompt text for filename pattern (will be sanitized)
  ///
  /// Returns a Stream of [DownloadProgress] for tracking download progress
  /// Throws exception if permission denied or download fails
  Stream<DownloadProgress> downloadImageToGallery({
    required String url,
    required String prompt,
  });

  /// Download document from URL and save to device downloads folder
  ///
  /// Parameters:
  /// - [url]: URL of the document to download
  /// - [fileName]: Filename including extension (e.g., 'document.pdf')
  ///
  /// Returns a Stream of [DownloadProgress] for tracking download progress
  /// Throws exception if permission denied or download fails
  Stream<DownloadProgress> downloadDocument({
    required String url,
    required String fileName,
  });

  /// Check and request storage permission if needed
  ///
  /// Returns true if permission is granted, false otherwise
  Future<bool> checkStoragePermission();
}
