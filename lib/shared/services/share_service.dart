import 'dart:io';

import 'package:datn_mobile/shared/services/download_service.dart';
import 'package:share_plus/share_plus.dart';

class ShareService {
  final DownloadService downloadService;

  ShareService(this.downloadService);

  Future<void> shareImage({required String url, String? prompt}) async {
    try {
      final filename = 'AIPrimary';
      String? filePath;

      await for (final progress in downloadService.downloadImageToGallery(
        url: url,
        prompt: filename,
        deleteOnComplete: false,
      )) {
        if (progress.filePath != null) {
          filePath = progress.filePath;
        }
      }

      if (filePath != null) {
        final file = XFile(filePath);

        // Share the file
        await SharePlus.instance.share(
          ShareParams(files: [file], text: prompt, subject: prompt),
        );

        // Cleanup after share
        try {
          File(filePath).deleteSync();
        } catch (_) {
          // Ignore
        }
      }
    } catch (e) {
      rethrow;
    }
  }
}
