/// Metadata for an uploaded attachment
class AttachmentMetadata {
  final String cdnUrl;
  final String fileName;
  final int? fileSize;
  final String? extension;
  final String mediaType;

  const AttachmentMetadata({
    required this.cdnUrl,
    required this.fileName,
    this.fileSize,
    this.extension,
    required this.mediaType,
  });

  String get fileSizeFormatted {
    if (fileSize == null) return 'Unknown size';

    final kb = fileSize! / 1024;
    if (kb < 1024) {
      return '${kb.toStringAsFixed(1)} KB';
    }

    final mb = kb / 1024;
    if (mb < 1024) {
      return '${mb.toStringAsFixed(1)} MB';
    }

    final gb = mb / 1024;
    return '${gb.toStringAsFixed(1)} GB';
  }

  bool get isImage => mediaType.startsWith('image');
}
