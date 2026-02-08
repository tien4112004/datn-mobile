import 'package:AIPrimary/shared/pods/translation_pod.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// A reusable dialog for confirming when users want to discard unsaved changes.
///
/// This provides a consistent UX across the app for handling unsaved changes
/// in forms and edit pages.
class UnsavedChangesDialog extends ConsumerWidget {
  final String? title;
  final String? content;
  final String? cancelLabel;
  final String? discardLabel;
  final VoidCallback? onDiscard;

  const UnsavedChangesDialog({
    super.key,
    this.title,
    this.content,
    this.cancelLabel,
    this.discardLabel,
    this.onDiscard,
  });

  /// Shows the unsaved changes dialog and returns true if user wants to discard.
  ///
  /// Returns `true` if user confirmed discard, `false` if cancelled, or `null`
  /// if dismissed without action.
  static Future<bool?> show(
    BuildContext context, {
    String? title,
    String? content,
    String? cancelLabel,
    String? discardLabel,
    VoidCallback? onDiscard,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (context) => UnsavedChangesDialog(
        title: title,
        content: content,
        cancelLabel: cancelLabel,
        discardLabel: discardLabel,
        onDiscard: onDiscard,
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(translationsPod);

    return AlertDialog(
      title: Text(title ?? t.common.unsavedChangesDialog.title),
      content: Text(content ?? t.common.unsavedChangesDialog.message),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(cancelLabel ?? t.common.unsavedChangesDialog.cancel),
        ),
        FilledButton(
          onPressed: () {
            onDiscard?.call();
            Navigator.of(context).pop(true);
          },
          child: Text(discardLabel ?? t.common.unsavedChangesDialog.discard),
        ),
      ],
    );
  }
}
