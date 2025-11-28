import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

enum ResourceType {
  document(label: "document", icon: LucideIcons.fileText, color: Colors.blue),
  image(label: "image", icon: LucideIcons.image, color: Colors.green),
  presentation(
    label: 'presentation',
    icon: LucideIcons.presentation,
    color: Colors.orange,
  ),

  mindmap(
    label: 'mindmap',
    icon: LucideIcons.brainCircuit,
    color: Colors.purple,
  );

  final String label;
  final IconData icon;
  final Color color;

  const ResourceType({
    required this.label,
    required this.icon,
    required this.color,
  });

  String getValue() {
    return label;
  }

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
