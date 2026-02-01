import 'package:AIPrimary/features/projects/domain/entity/value_object/slide.dart';

class Presentation {
  String id;
  String title;
  List<Slide> slides;
  DateTime createdAt;
  DateTime updatedAt;
  bool isParsed;
  Object metaData;
  DateTime deletedAt;
  Map<String, double> viewport;

  Presentation({
    required this.id,
    required this.title,
    required this.slides,
    required this.createdAt,
    required this.updatedAt,
    required this.isParsed,
    required this.metaData,
    required this.deletedAt,
    required this.viewport,
  });

  String? get thumbnail => null;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'slides': slides.map((slide) => slide.toJson()).toList(),
      'viewport': viewport,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}
