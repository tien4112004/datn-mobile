import 'dart:math';

// ── Base ID generation ──

/// Generate a unique ID: timestamp(base36)-random(base36)
/// Mirrors `@aiprimary/core` generateId() in TypeScript.
String generateId() {
  final timestamp = DateTime.now().millisecondsSinceEpoch.toRadixString(36);
  final random = Random().nextInt(4294967296).toRadixString(36).padLeft(7, '0');
  return '$timestamp-$random';
}

// ── Domain-specific ID builders ──

/// Generate a topic ID with prefix: topic-{generateId()}
String createTopicId() => 'topic-${generateId()}';

// ── Matrix Cell ID ──

/// Create a cell ID from components: {topicId}-{difficulty}-{questionType}
String createCellId(String topicId, String difficulty, String questionType) {
  return '$topicId-$difficulty-$questionType';
}

/// Parse a cell ID back into its components.
/// Returns null if the cellId doesn't have enough parts.
///
/// The topicId may contain dashes (e.g. "topic-abc123-def"),
/// so we pop from the end: questionType, difficulty, then join the rest as topicId.
({String topicId, String difficulty, String questionType})? parseCellId(
  String cellId,
) {
  final parts = cellId.split('-');
  if (parts.length < 3) return null;

  final questionType = parts.removeLast();
  final difficulty = parts.removeLast();
  final topicId = parts.join('-');

  return (topicId: topicId, difficulty: difficulty, questionType: questionType);
}
