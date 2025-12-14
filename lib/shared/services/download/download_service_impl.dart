import 'dart:async';
import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:dio/dio.dart';
import 'package:gal/gal.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

import 'download_service.dart';
import 'models/download_progress.dart';

/// Implementation of DownloadService
/// Handles file downloading with progress tracking and storage management
class DownloadServiceImpl implements DownloadService {
  final Dio _dio;

  DownloadServiceImpl(this._dio);

  /// Sanitize filename by removing/replacing invalid characters
  String _sanitizeFilename(String filename) {
    // Remove or replace invalid filename characters
    return filename
        .replaceAll(RegExp(r'[<>:"/\\|?*]'), '_')
        .replaceAll(RegExp(r'\s+'), '_')
        .trim();
  }

  /// Get file extension from URL or default to .jpg
  String _getFileExtension(String url) {
    try {
      final uri = Uri.parse(url);
      final path = uri.path.toLowerCase();

      if (path.contains('.jpg') || path.contains('.jpeg')) return '.jpg';
      if (path.contains('.png')) return '.png';
      if (path.contains('.gif')) return '.gif';
      if (path.contains('.webp')) return '.webp';

      return '.jpg'; // Default for images
    } catch (_) {
      return '.jpg';
    }
  }

  /// Get document file extension from URL or use provided name
  String _getDocumentExtension(String fileName) {
    try {
      final uri = Uri.parse(fileName);
      final path = uri.path.toLowerCase();

      if (path.contains('.')) {
        return '';
      }

      return '.pdf'; // Default for documents
    } catch (_) {
      return '';
    }
  }

  @override
  Stream<DownloadProgress> downloadImageToGallery({
    required String url,
    required String prompt,
  }) async* {
    final controller = StreamController<DownloadProgress>();

    try {
      // Check permission
      // On Android 10+ (SDK 29+), we don't need permission to save images to gallery using Gal
      bool requiresPermission = true;
      if (Platform.isAndroid) {
        final sdkInt = await _getAndroidVersion();
        if (sdkInt >= 29) {
          requiresPermission = false;
        }
      }

      if (requiresPermission) {
        final hasPermission = await checkStoragePermission();
        if (!hasPermission) {
          throw Exception('Storage permission denied');
        }
      }

      // Sanitize prompt and create filename
      final sanitizedPrompt = _sanitizeFilename(prompt);
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final extension = _getFileExtension(url);
      final filename = '${sanitizedPrompt}_$timestamp$extension';

      // Get temporary directory
      final tempDir = await getTemporaryDirectory();
      final filePath = '${tempDir.path}/$filename';

      // Download file with progress tracking
      await _dio.download(
        url,
        filePath,
        onReceiveProgress: (received, total) {
          controller.add(DownloadProgress(received: received, total: total));
        },
      );

      // Save to gallery
      await Gal.putImage(filePath);

      // Clean up temporary file
      try {
        File(filePath).deleteSync();
      } catch (_) {
        // Ignore cleanup errors
      }

      controller.close();
    } catch (e) {
      controller.addError(e);
      controller.close();
      rethrow;
    }

    yield* controller.stream;
  }

  @override
  Stream<DownloadProgress> downloadDocument({
    required String url,
    required String fileName,
  }) async* {
    final controller = StreamController<DownloadProgress>();

    try {
      // Check permission
      final hasPermission = await checkStoragePermission();
      if (!hasPermission) {
        throw Exception('Storage permission denied');
      }

      // Ensure proper filename
      String finalFileName = fileName;
      if (!fileName.contains('.')) {
        finalFileName = '$fileName${_getDocumentExtension(url)}';
      }
      finalFileName = _sanitizeFilename(finalFileName);

      // Get downloads directory
      String downloadPath;
      try {
        // Try to get public downloads directory
        final externalDir = await getExternalStorageDirectory();
        if (externalDir != null) {
          // Navigate to actual Downloads folder
          downloadPath = externalDir.path.replaceAll(
            '/Android/data/com.example.datn_mobile/files',
            '/Download',
          );
        } else {
          // Fallback to app documents directory
          final docsDir = await getApplicationDocumentsDirectory();
          downloadPath = docsDir.path;
        }
      } catch (_) {
        // Fallback to app documents directory
        final docsDir = await getApplicationDocumentsDirectory();
        downloadPath = docsDir.path;
      }

      // Ensure directory exists
      final directory = Directory(downloadPath);
      if (!await directory.exists()) {
        await directory.create(recursive: true);
      }

      final filePath = '$downloadPath/$finalFileName';

      // Download file with progress tracking
      await _dio.download(
        url,
        filePath,
        onReceiveProgress: (received, total) {
          controller.add(DownloadProgress(received: received, total: total));
        },
      );

      controller.close();
    } catch (e) {
      controller.addError(e);
      controller.close();
      rethrow;
    }

    yield* controller.stream;
  }

  @override
  Future<bool> checkStoragePermission() async {
    try {
      PermissionStatus status;

      if (Platform.isAndroid) {
        // For Android 13+ (SDK 33+) use photo permission
        final sdkInt = await _getAndroidVersion();
        if (sdkInt >= 33) {
          status = await Permission.photos.request();
        } else {
          // For older Android use storage permission
          status = await Permission.storage.request();
        }
      } else if (Platform.isIOS) {
        status = await Permission.photos.request();
      } else {
        return true; // Other platforms
      }

      return status.isGranted;
    } catch (_) {
      return false;
    }
  }

  /// Get Android version
  Future<int> _getAndroidVersion() async {
    try {
      final info = await _getDeviceInfo();
      return info;
    } catch (_) {
      return 28; // Default to assume older version
    }
  }

  /// Get device info (Android SDK version)
  Future<int> _getDeviceInfo() async {
    try {
      if (Platform.isAndroid) {
        final androidInfo = await DeviceInfoPlugin().androidInfo;
        return androidInfo.version.sdkInt;
      }
      return 0;
    } catch (_) {
      return 28;
    }
  }
}
