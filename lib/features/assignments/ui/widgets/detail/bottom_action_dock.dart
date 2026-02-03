import 'package:AIPrimary/shared/pods/translation_pod.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// Bottom action dock for save/cancel operations in edit mode.
/// Follows Material Design 3 with elevated styling.
class BottomActionDock extends ConsumerWidget {
  final VoidCallback onCancel;
  final VoidCallback onSave;
  final bool isSaving;

  const BottomActionDock({
    super.key,
    required this.onCancel,
    required this.onSave,
    this.isSaving = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final t = ref.watch(translationsPod);

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
        border: Border(
          top: BorderSide(
            color: colorScheme.outlineVariant.withValues(alpha: 0.5),
            width: 1,
          ),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              // Cancel button
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: isSaving ? null : onCancel,
                  icon: const Icon(LucideIcons.x, size: 18),
                  label: Text(t.assignments.actionDock.cancel),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // Save button
              Expanded(
                child: FilledButton.icon(
                  onPressed: isSaving ? null : onSave,
                  icon: isSaving
                      ? SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              colorScheme.onPrimary,
                            ),
                          ),
                        )
                      : const Icon(LucideIcons.save, size: 18),
                  label: Text(
                    isSaving
                        ? t.assignments.actionDock.saving
                        : t.assignments.actionDock.saveChanges,
                  ),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
