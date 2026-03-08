/// A segment of comment content — either plain text or an embedded post mention.
sealed class ContentSegment {
  const ContentSegment();
}

class TextSegment extends ContentSegment {
  final String text;
  const TextSegment(this.text);
}

class PostMentionSegment extends ContentSegment {
  final String classId;
  final String postId;
  final String previewTitle;

  const PostMentionSegment({
    required this.classId,
    required this.postId,
    required this.previewTitle,
  });
}

/// Parses raw comment content into [ContentSegment] list.
///
/// Post mention tokens have the format:
///   /classes/{classId}/posts/{postId}?preview={encoded-title}
class PostMentionParser {
  static final _mentionPattern = RegExp(
    r'/classes/([^/\s]+)/posts/([^?\s]+)\?preview=([^\s]+)',
  );

  /// Parses [content] into alternating [TextSegment] and [PostMentionSegment].
  static List<ContentSegment> parse(String content) {
    final segments = <ContentSegment>[];
    int lastEnd = 0;

    for (final match in _mentionPattern.allMatches(content)) {
      if (match.start > lastEnd) {
        final text = content.substring(lastEnd, match.start);
        if (text.isNotEmpty) segments.add(TextSegment(text));
      }

      segments.add(
        PostMentionSegment(
          classId: match.group(1)!,
          postId: match.group(2)!,
          previewTitle: Uri.decodeComponent(match.group(3)!),
        ),
      );

      lastEnd = match.end;
    }

    if (lastEnd < content.length) {
      final text = content.substring(lastEnd);
      if (text.isNotEmpty) segments.add(TextSegment(text));
    }

    // No tokens found — treat entire string as plain text.
    return segments.isEmpty ? [TextSegment(content)] : segments;
  }

  /// Returns true if [content] contains at least one post mention token.
  static bool hasMentions(String content) => _mentionPattern.hasMatch(content);

  /// Builds a URL-style mention token to embed in comment content.
  static String buildMentionToken({
    required String classId,
    required String postId,
    required String previewTitle,
  }) {
    // Normalise: strip newlines, trim, cap at 80 chars.
    final normalised = previewTitle
        .replaceAll('\n', ' ')
        .replaceAll('\r', '')
        .trim();
    final capped = normalised.length > 80
        ? '${normalised.substring(0, 80)}…'
        : normalised;
    return '/classes/$classId/posts/$postId?preview=${Uri.encodeComponent(capped)}';
  }
}
