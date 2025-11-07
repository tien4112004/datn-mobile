import 'package:datn_mobile/features/projects/domain/entity/value_object/slide.dart';

class PresentationMinimal {
  final String id;
  final String title;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final Slide? thumbnail;

  const PresentationMinimal({
    required this.id,
    required this.title,
    this.createdAt,
    this.updatedAt,
    this.thumbnail,
  });

  PresentationMinimal copyWith({
    String? id,
    String? title,
    DateTime? createdAt,
    DateTime? updatedAt,
    Slide? thumbnail,
  }) {
    return PresentationMinimal(
      id: id ?? this.id,
      title: title ?? this.title,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      thumbnail: thumbnail ?? this.thumbnail,
    );
  }
}
