import 'package:AIPrimary/core/theme/app_theme.dart';
import 'package:AIPrimary/features/generate/enum/generator_type.dart';
import 'package:AIPrimary/features/generate/states/controller_provider.dart';
import 'package:AIPrimary/features/generate/ui/widgets/shared/picker_bottom_sheet.dart';
import 'package:AIPrimary/i18n/strings.g.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Bottom sheet for selecting generator type (Presentation, Mindmap, Image)
class GeneratorPickerSheet extends ConsumerStatefulWidget {
  final Translations t;

  const GeneratorPickerSheet({super.key, required this.t});

  static Widget show(BuildContext context, Translations t) {
    PickerBottomSheet.show(
      context: context,
      title: t.generate.presentationGenerate.selectGenerator,
      child: GeneratorPickerSheet(t: t),
    );
    return const SizedBox.shrink();
  }

  @override
  ConsumerState<GeneratorPickerSheet> createState() =>
      _GeneratorPickerSheetState();
}

class _GeneratorPickerSheetState extends ConsumerState<GeneratorPickerSheet> {
  @override
  Widget build(BuildContext context) {
    final currentGeneratorType = ref.watch(generatorTypeProvider);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Options
        ...GeneratorType.values.map((type) {
          final isSelected = currentGeneratorType == type;
          return ListTile(
            leading: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isSelected
                    ? type.resourceType.color.withValues(alpha: 0.1)
                    : context.secondarySurfaceColor,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                type.resourceType.icon,
                color: isSelected
                    ? type.resourceType.color
                    : context.secondaryTextColor,
              ),
            ),
            title: Text(
              type.getLabel(widget.t),
              style: TextStyle(
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                color: Themes.theme.textTheme.bodyLarge?.color,
              ),
            ),
            trailing: isSelected
                ? Icon(
                    Icons.check_circle_rounded,
                    color: Theme.of(context).colorScheme.primary,
                  )
                : null,
            onTap: () {
              Navigator.pop(context);
              _onGeneratorTypeChanged(type);
            },
          );
        }),
      ],
    );
  }

  void _onGeneratorTypeChanged(GeneratorType type) {
    final currentType = ref.read(generatorTypeProvider);

    if (currentType != type) {
      // Update the active generator type
      ref.read(generatorTypeProvider.notifier).state = type;

      // Reset form and generate states for the previous generator
      switch (currentType) {
        case GeneratorType.presentation:
          ref.read(presentationFormControllerProvider.notifier).reset();
          ref.read(presentationGenerateControllerProvider.notifier).reset();
          break;
        case GeneratorType.mindmap:
          ref.read(mindmapFormControllerProvider.notifier).reset();
          ref.read(mindmapGenerateControllerProvider.notifier).reset();
          break;
        case GeneratorType.image:
          ref.read(imageFormControllerProvider.notifier).reset();
          ref.read(imageGenerateControllerProvider.notifier).reset();
          break;
      }
    }
  }
}
