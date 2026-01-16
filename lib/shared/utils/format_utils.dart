/// Formats file size in bytes to human-readable string
String formatFileSize(int bytes) {
  if (bytes < 0) {
    return '0 B';
  }

  if (bytes < 1024) {
    return '$bytes B';
  }

  if (bytes < 1024 * 1024) {
    final kb = bytes / 1024;
    return '${kb.toStringAsFixed(1)} KB';
  }

  if (bytes < 1024 * 1024 * 1024) {
    final mb = bytes / (1024 * 1024);
    return '${mb.toStringAsFixed(1)} MB';
  }

  final gb = bytes / (1024 * 1024 * 1024);
  return '${gb.toStringAsFixed(1)} GB';
}

/// Formats media type enum to user-friendly display string
String formatMediaType(String mediaType) {
  if (mediaType.startsWith('IMAGE_')) {
    return mediaType.substring(6); // Remove "IMAGE_" prefix
  }
  return mediaType;
}
