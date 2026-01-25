import 'package:flutter/material.dart';

/// A reusable dialog for confirming when users want to discard unsaved changes.
///
/// This provides a consistent UX across the app for handling unsaved changes
/// in forms and edit pages.
class UnsavedChangesDialog extends StatelessWidget {
  final String title;
  final String content;
  final String cancelLabel;
  final String discardLabel;
  final VoidCallback? onDiscard;

  const UnsavedChangesDialog({
    super.key,
    this.title = 'Discard changes?',
    this.content = 'You have unsaved changes. Are you sure you want to leave?',
    this.cancelLabel = 'Cancel',
    this.discardLabel = 'Discard',
    this.onDiscard,
  });

  /// Shows the unsaved changes dialog and returns true if user wants to discard.
  ///
  /// Returns `true` if user confirmed discard, `false` if cancelled, or `null`
  /// if dismissed without action.
  static Future<bool?> show(
    BuildContext context, {
    String title = 'Discard changes?',
    String content =
        'You have unsaved changes. Are you sure you want to leave?',
    String cancelLabel = 'Cancel',
    String discardLabel = 'Discard',
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
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title),
      content: Text(content),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(cancelLabel),
        ),
        FilledButton(
          onPressed: () {
            onDiscard?.call();
            Navigator.of(context).pop(true);
          },
          child: Text(discardLabel),
        ),
      ],
    );
  }
}
