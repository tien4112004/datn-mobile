import 'package:datn_mobile/features/generate/domain/entity/ai_model.dart';
import 'package:datn_mobile/i18n/strings.g.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

enum ResourceType {
  assignment(
    label: 'assignment',
    icon: LucideIcons.clipboardList,
    color: Colors.indigo,
    modelType: ModelType.text,
  ),
  image(
    label: "image",
    icon: LucideIcons.image,
    color: Colors.green,
    modelType: ModelType.image,
  ),
  mindmap(
    label: 'mindmap',
    icon: LucideIcons.brainCircuit,
    color: Colors.purple,
    modelType: ModelType.text,
  ),
  presentation(
    label: 'presentation',
    icon: LucideIcons.presentation,
    color: Colors.orange,
    modelType: ModelType.text,
  ),
  question(
    label: 'question',
    icon: LucideIcons.fileQuestionMark,
    color: Colors.teal,
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

  String getLabel(Translations t) {
    switch (this) {
      case ResourceType.assignment:
        return 'Assignments';
      case ResourceType.image:
        return t.generate.resourceTypes.image;
      case ResourceType.mindmap:
        return t.generate.resourceTypes.mindmap;
      case ResourceType.presentation:
        return t.generate.resourceTypes.presentation;
      case ResourceType.question:
        return 'Questions Bank';
    }
  }

  static List<String> getLabels(Translations t) {
    return [for (var type in ResourceType.values) type.getLabel(t)];
  }
}
