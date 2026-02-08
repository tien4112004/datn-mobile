import 'package:AIPrimary/features/classes/states/resrouce_selection_state.dart';
import 'package:AIPrimary/shared/pods/translation_pod.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class SheetHeader extends ConsumerWidget {
  final SelectionStep currentStep;
  final int selectedCount;
  final VoidCallback onClose;
  final VoidCallback onBack;
  final VoidCallback onContinue;
  final VoidCallback onDone;

  const SheetHeader({
    super.key,
    required this.currentStep,
    required this.selectedCount,
    required this.onClose,
    required this.onBack,
    required this.onContinue,
    required this.onDone,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(translationsPod);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Title
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            switchInCurve: Curves.easeOut,
            switchOutCurve: Curves.easeIn,
            transitionBuilder: (child, animation) {
              return FadeTransition(
                opacity: animation,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, 0.1),
                    end: Offset.zero,
                  ).animate(animation),
                  child: child,
                ),
              );
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  currentStep == SelectionStep.pickResources
                      ? t.classes.resourceSelector.selectResources
                      : t.classes.resourceSelector.configurePermissions,
                  key: ValueKey(currentStep),
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                ),
                Text(
                  t.classes.resourceSelector.selectedCount(
                    count: selectedCount,
                  ),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),

          // Trailing action button
          _buildTrailingButton(context, t),
        ],
      ),
    );
  }

  Widget _buildTrailingButton(BuildContext context, dynamic t) {
    if (currentStep == SelectionStep.pickResources) {
      return FilledButton.icon(
        onPressed: selectedCount == 0 ? null : onContinue,
        icon: const Icon(LucideIcons.arrowRight, size: 18),
        label: Text(t.classes.resourceSelector.continue_),
        style: FilledButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        ),
      );
    } else {
      return FilledButton.icon(
        onPressed: onDone,
        icon: const Icon(LucideIcons.check, size: 18),
        label: Text(t.classes.resourceSelector.done),
        style: FilledButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        ),
      );
    }
  }
}
