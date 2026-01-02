import 'package:flutter/material.dart';

/// Domain entity for a class/course.
/// Pure business object without JSON annotations.
class ClassEntity {
  final String id;
  final String ownerId;
  final String name;
  final String? joinCode;
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  /// Optional instructor name (derived from owner info).
  final String? instructorName;

  /// Optional class description.
  final String? description;

  const ClassEntity({
    required this.id,
    required this.ownerId,
    required this.name,
    this.joinCode,
    required this.isActive,
    this.createdAt,
    this.updatedAt,
    this.instructorName,
    this.description,
  });

  /// Google Classroom-style header colors.
  /// Returns a color based on the class ID hash for consistent coloring.
  static const List<Color> _headerColors = [
    Color.fromARGB(255, 91, 169, 238), // Blue
    Color.fromARGB(255, 67, 160, 71), // Green
    Color.fromARGB(255, 255, 192, 45), // Yellow
    Color.fromARGB(255, 229, 57, 53), // Red
    Color.fromARGB(255, 142, 36, 170), // Purple
    Color.fromARGB(255, 0, 172, 193), // Cyan
    Color.fromARGB(255, 255, 112, 67), // Deep Orange
    Color.fromARGB(255, 92, 107, 192), // Indigo
  ];

  /// Gets a consistent header color based on class ID.
  Color get headerColor {
    final index = id.hashCode.abs() % _headerColors.length;
    return _headerColors[index];
  }

  /// Gets the display name for the instructor.
  String get displayInstructorName => instructorName ?? 'Instructor';

  ClassEntity copyWith({
    String? id,
    String? ownerId,
    String? name,
    String? joinCode,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? instructorName,
    String? description,
  }) {
    return ClassEntity(
      id: id ?? this.id,
      ownerId: ownerId ?? this.ownerId,
      name: name ?? this.name,
      joinCode: joinCode ?? this.joinCode,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      instructorName: instructorName ?? this.instructorName,
      description: description ?? this.description,
    );
  }
}
