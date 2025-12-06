import 'package:datn_mobile/features/generate/domain/entity/ai_model.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

enum ResourceType {
  document(
    label: "document",
    icon: LucideIcons.fileText,
    color: Colors.blue,
    modelType: ModelType.text,
  ),
  image(
    label: "image",
    icon: LucideIcons.image,
    color: Colors.green,
    modelType: ModelType.image,
  ),
  presentation(
    label: 'presentation',
    icon: LucideIcons.presentation,
    color: Colors.orange,
    modelType: ModelType.text,
  ),
  mindmap(
    label: 'mindmap',
    icon: LucideIcons.brainCircuit,
    color: Colors.purple,
    modelType: ModelType.text,
  );

  final String label;
  final IconData icon;
  final Color color;
  final ModelType modelType;

  const ResourceType({
    required this.label,
    required this.icon,
    required this.color,
    required this.modelType,
  });

  String getValue() {
    return label;
  }

  ModelType get modelTypeValue => modelType;

  @override
  String toString() {
    return label;
  }

  static ResourceType fromValue(String value) {
    for (ResourceType type in ResourceType.values) {
      if (type.getValue() == value) {
        return type;
      }
    }
    throw ArgumentError("Invalid ResourceType value: $value");
  }
}
