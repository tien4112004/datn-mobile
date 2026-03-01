import 'package:AIPrimary/features/students/domain/entity/student.dart';
import 'package:AIPrimary/shared/pods/translation_pod.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// Dialog to display student credentials after successful account creation.
/// Shows username and password with copy functionality and security warning.
class StudentCredentialsDialog extends ConsumerStatefulWidget {
  final Student student;

  const StudentCredentialsDialog({super.key, required this.student});

  /// Shows the credentials dialog.
  static Future<void> show(BuildContext context, Student student) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => StudentCredentialsDialog(student: student),
    );
  }

  @override
  ConsumerState<StudentCredentialsDialog> createState() =>
      _StudentCredentialsDialogState();
}

class _StudentCredentialsDialogState
    extends ConsumerState<StudentCredentialsDialog> {
  bool _isPasswordVisible = false;

  void _copyToClipboard(BuildContext context, String text, String label) {
    final t = ref.read(translationsPod);
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(t.students.credentials.copiedToClipboard(label: label)),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = ref.watch(translationsPod);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return AlertDialog(
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer,
              shape: BoxShape.circle,
            ),
            child: Icon(
              LucideIcons.circleCheck,
              color: colorScheme.primary,
              size: 28,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              t.students.credentials.dialogTitle,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Student name
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    t.students.credentials.studentLabel,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.student.fullName,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Credentials section
            Text(
              t.students.credentials.accountCredentials,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.primary,
              ),
            ),
            const SizedBox(height: 12),

            // Username field
            _CredentialField(
              label: t.students.credentials.username,
              value:
                  widget.student.username ??
                  t.students.credentials.notAvailable,
              icon: LucideIcons.user,
              onCopy: () => _copyToClipboard(
                context,
                widget.student.username ?? '',
                t.students.credentials.username,
              ),
            ),
            const SizedBox(height: 12),

            // Password field
            _CredentialField(
              label: t.students.credentials.password,
              value:
                  widget.student.password ??
                  t.students.credentials.notAvailable,
              icon: LucideIcons.lock,
              isPassword: true,
              isPasswordVisible: _isPasswordVisible,
              onToggleVisibility: () {
                setState(() {
                  _isPasswordVisible = !_isPasswordVisible;
                });
              },
              onCopy: () => _copyToClipboard(
                context,
                widget.student.password ?? '',
                t.students.credentials.password,
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
      actions: [
        FilledButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(t.common.done),
        ),
      ],
    );
  }
}

/// Widget for displaying a single credential field with copy functionality.
class _CredentialField extends ConsumerWidget {
  final String label;
  final String value;
  final IconData icon;
  final bool isPassword;
  final bool isPasswordVisible;
  final VoidCallback? onToggleVisibility;
  final VoidCallback onCopy;

  const _CredentialField({
    required this.label,
    required this.value,
    required this.icon,
    this.isPassword = false,
    this.isPasswordVisible = false,
    this.onToggleVisibility,
    required this.onCopy,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(translationsPod);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: colorScheme.primary),
              const SizedBox(width: 6),
              Text(
                label,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: SelectableText(
                  isPassword && !isPasswordVisible ? '••••••••' : value,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontFamily: 'monospace',
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              if (isPassword && onToggleVisibility != null)
                IconButton(
                  icon: Icon(
                    isPasswordVisible ? LucideIcons.eyeOff : LucideIcons.eye,
                    size: 20,
                  ),
                  onPressed: onToggleVisibility,
                  tooltip: isPasswordVisible ? t.common.hide : t.common.show,
                  visualDensity: VisualDensity.compact,
                ),
              IconButton(
                icon: const Icon(LucideIcons.copy, size: 20),
                onPressed: onCopy,
                tooltip: t.common.copy,
                visualDensity: VisualDensity.compact,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
