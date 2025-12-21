import 'package:datn_mobile/features/projects/enum/resource_type.dart';
import 'package:datn_mobile/i18n/strings.g.dart';

/// Generator types available in the app
enum GeneratorType {
  presentation(ResourceType.presentation),
  image(ResourceType.image),
  mindmap(ResourceType.mindmap);

  final ResourceType resourceType;

  const GeneratorType(this.resourceType);

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
