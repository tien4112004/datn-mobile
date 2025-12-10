import 'package:datn_mobile/core/theme/app_theme.dart';
import 'package:datn_mobile/features/generate/enum/generator_type.dart';
import 'package:datn_mobile/features/generate/states/controller_provider.dart';
import 'package:datn_mobile/i18n/strings.g.dart';
import 'package:datn_mobile/shared/utils/snackbar_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Bottom sheet for selecting generator type (Presentation, Mindmap, Image)
class GeneratorPickerSheet extends ConsumerStatefulWidget {
  final Translations t;

  const GeneratorPickerSheet({super.key, required this.t});

  static Widget show(BuildContext context, Translations t) {
    showModalBottomSheet(
      context: context,
      backgroundColor: context.surfaceColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (bottomSheetContext) => GeneratorPickerSheet(t: t),
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
        const SizedBox(height: 12),
        // Handle
        Container(
          width: 40,
          height: 4,
          decoration: BoxDecoration(
            color: context.dividerColor,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(height: 16),
        // Title
        Text(
          widget.t.generate.presentationGenerate.selectGenerator,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: context.isDarkMode ? Colors.white : Colors.grey[900],
          ),
        ),
        const SizedBox(height: 8),
        // Options
        ...GeneratorType.values.map((type) {
          final isSelected = currentGeneratorType == type;
          return ListTile(
            leading: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isSelected
                    ? Theme.of(
                        context,
                      ).colorScheme.primary.withValues(alpha: 0.1)
                    : context.secondarySurfaceColor,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                type.icon,
                color: isSelected
                    ? Theme.of(context).colorScheme.primary
                    : context.secondaryTextColor,
              ),
            ),
            title: Text(
              type.getLabel(widget.t),
              style: TextStyle(
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: context.isDarkMode ? Colors.white : Colors.grey[900],
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
        SizedBox(height: MediaQuery.of(context).padding.bottom + 16),
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
          // No state to reset for image generator yet
          break;
      }

      // Show coming soon message for image generator
      if (type == GeneratorType.image) {
        SnackbarUtils.showInfo(
          context,
          widget.t.generate.presentationGenerate.generatorComingSoon(
            type: type.getLabel(widget.t),
          ),
        );
      }
    }
  }
}
