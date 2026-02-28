import 'package:AIPrimary/features/auth/domain/entities/user_role.dart';
import 'package:AIPrimary/i18n/strings.g.dart';
import 'package:AIPrimary/shared/pods/translation_pod.dart';
import 'package:AIPrimary/shared/pods/user_profile_pod.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// Invisible widget that automatically shows a one-time dialog on first frame,
/// reminding teachers that edit mode is better on the desktop web version.
/// Renders nothing — place it anywhere inside a Stack or widget tree.
class DesktopHintDialog extends ConsumerStatefulWidget {
  const DesktopHintDialog({super.key});

  @override
  ConsumerState<DesktopHintDialog> createState() => _DesktopHintDialogState();
}

class _DesktopHintDialogState extends ConsumerState<DesktopHintDialog> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (ref.read(userRolePod) != UserRole.teacher) return;
      _showDialog(ref.read(translationsPod));
    });
  }

  void _showDialog(Translations t) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        contentPadding: const EdgeInsets.fromLTRB(24, 28, 24, 8),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.indigo.shade50,
                shape: BoxShape.circle,
              ),
              child: Icon(
                LucideIcons.monitorCheck,
                size: 36,
                color: Colors.indigo.shade600,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              t.projects.desktopHint.dialogTitle,
              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              t.projects.desktopHint.dialogMessage,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13.5,
                color: Colors.grey.shade600,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 4),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(t.projects.desktopHint.dialogAction),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}
