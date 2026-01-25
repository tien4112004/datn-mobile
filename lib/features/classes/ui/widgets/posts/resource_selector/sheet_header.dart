import 'package:datn_mobile/features/classes/states/resrouce_selection_state.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class SheetHeader extends StatelessWidget {
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
  Widget build(BuildContext context) {
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
                      ? 'Select Resources'
                      : 'Configure Permissions',
                  key: ValueKey(currentStep),
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                ),
                Text(
                  '$selectedCount selected',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),

          // Trailing action button
          _buildTrailingButton(context),
        ],
      ),
    );
  }

  Widget _buildTrailingButton(BuildContext context) {
    if (currentStep == SelectionStep.pickResources) {
      return FilledButton.icon(
        onPressed: selectedCount == 0 ? null : onContinue,
        icon: const Icon(LucideIcons.arrowRight, size: 18),
        label: const Text('Continue'),
        style: FilledButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        ),
      );
    } else {
      return FilledButton.icon(
        onPressed: onDone,
        icon: const Icon(LucideIcons.check, size: 18),
        label: const Text('Done'),
        style: FilledButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        ),
      );
    }
  }
}
