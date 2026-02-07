/// Preview data for a linked resource
class LinkedResourcePreview {
  final String id;
  final String title;
  final String type; // 'presentation', 'mindmap', 'image', 'assignment', etc.
  final String? thumbnail;
  final DateTime? updatedAt;

  // Assignment-specific metadata
  final String? subject;
  final String? gradeLevel;
  final int? totalQuestions;
  final int? totalPoints;
  final String? status;
  final String? description;

  const LinkedResourcePreview({
    required this.id,
    required this.title,
    required this.type,
    this.thumbnail,
    this.updatedAt,
    this.subject,
    this.gradeLevel,
    this.totalQuestions,
    this.totalPoints,
    this.status,
    this.description,
  });

  factory LinkedResourcePreview.placeholder(String id) {
    return LinkedResourcePreview(id: id, title: 'Loading...', type: 'unknown');
  }

  factory LinkedResourcePreview.error(String id) {
    return LinkedResourcePreview(
      id: id,
      title: 'Resource not found',
      type: 'error',
    );
  }

  bool get isValid => type != 'unknown' && type != 'error';
}
