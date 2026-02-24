import 'package:AIPrimary/features/projects/enum/resource_type.dart';
import 'package:AIPrimary/i18n/strings.g.dart';

/// Generator types available in the app
enum GeneratorType {
  presentation(ResourceType.presentation),
  image(ResourceType.image),
  mindmap(ResourceType.mindmap),
  question(ResourceType.question),
  assignment(ResourceType.assignment);

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
      case GeneratorType.question:
        return t.generate.generatorTypes.question;
      case GeneratorType.assignment:
        return t.generate.generatorTypes.assignment;
    }
  }
}
