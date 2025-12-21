import 'package:datn_mobile/i18n/strings.g.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// Generator types available in the app
enum GeneratorType {
  presentation(LucideIcons.presentation),
  image(LucideIcons.image),
  mindmap(LucideIcons.brainCircuit);

  final IconData icon;

  const GeneratorType(this.icon);

  String getLabel(Translations t) {
    switch (this) {
      case GeneratorType.presentation:
        return t.generate.generatorTypes.presentation;
      case GeneratorType.image:
        return t.generate.generatorTypes.image;
      case GeneratorType.mindmap:
        return t.generate.generatorTypes.mindmap;
    }
  }
}
