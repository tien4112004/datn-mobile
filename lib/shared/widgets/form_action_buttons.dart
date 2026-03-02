import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:AIPrimary/shared/pods/translation_pod.dart';

/// A reusable widget for displaying save/cancel action buttons at the bottom
/// of forms.
///
/// Provides a consistent button layout with cancel (outlined) and save (filled)
/// buttons that handle loading states.
class FormActionButtons extends ConsumerWidget {
  final VoidCallback? onCancel;
  final VoidCallback? onSave;
  final bool isLoading;
  final bool isEditing;
  final String? cancelLabel;
  final String? saveLabel;
  final String? updateLabel;

  const FormActionButtons({
    super.key,
    required this.onCancel,
    required this.onSave,
    this.isLoading = false,
    this.isEditing = false,
    this.cancelLabel,
    this.saveLabel,
    this.updateLabel,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(translationsPod);
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: isLoading ? null : onCancel,
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(cancelLabel ?? t.common.cancel),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: FilledButton(
            onPressed: isLoading ? null : onSave,
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              isEditing
                  ? (updateLabel ?? t.common.update)
                  : (saveLabel ?? t.common.create),
            ),
          ),
        ),
      ],
    );
  }
}
