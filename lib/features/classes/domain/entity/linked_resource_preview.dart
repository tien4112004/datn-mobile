/// Preview data for a linked resource
class LinkedResourcePreview {
  final String id;
  final String title;
  final String type; // 'presentation', 'mindmap', 'image', etc.
  final String? thumbnail;
  final DateTime? updatedAt;

  const LinkedResourcePreview({
    required this.id,
    required this.title,
    required this.type,
    this.thumbnail,
    this.updatedAt,
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
