/// Entity representing a single slide in the presentation outline.
class OutlineSlide {
  final int order;
  final String title;
  final String content;

  const OutlineSlide({
    required this.order,
    required this.title,
    required this.content,
  });

  OutlineSlide copyWith({int? order, String? title, String? content}) {
    return OutlineSlide(
      order: order ?? this.order,
      title: title ?? this.title,
      content: content ?? this.content,
    );
  }

  Map<String, dynamic> toJson() => {
    'order': order,
    'title': title,
    'content': content,
  };

  factory OutlineSlide.fromJson(Map<String, dynamic> json) {
    return OutlineSlide(
      order: json['order'] as int,
      title: json['title'] as String,
      content: json['content'] as String,
    );
  }

  @override
  String toString() {
    return 'OutlineSlide(order: $order, title: $title, content: $content)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is OutlineSlide &&
        other.order == order &&
        other.title == title &&
        other.content == content;
  }

  @override
  int get hashCode => order.hashCode ^ title.hashCode ^ content.hashCode;
}
