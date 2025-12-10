class SlideViewport {
  final double width;
  final double height;

  const SlideViewport({required this.width, required this.height});

  factory SlideViewport.fromJson(Map<String, dynamic> json) {
    return SlideViewport(
      width: (json['width'] as num).toDouble(),
      height: (json['height'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {'width': width, 'height': height};

  // Standard viewport ratio (16:9)
  static const standard = SlideViewport(width: 1000, height: 562.5);
}
