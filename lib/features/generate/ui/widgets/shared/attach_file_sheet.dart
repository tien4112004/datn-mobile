import 'package:AIPrimary/features/generate/ui/widgets/shared/picker_bottom_sheet.dart';
import 'package:AIPrimary/i18n/strings.g.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// Bottom sheet for attaching files to resource generation
/// Displays options for document, image, and link attachments
class AttachFileSheet extends StatelessWidget {
  final Translations t;
  final VoidCallback onDocumentTap;
  final VoidCallback onImageTap;
  final VoidCallback onLinkTap;

  const AttachFileSheet({
    super.key,
    required this.t,
    required this.onDocumentTap,
    required this.onImageTap,
    required this.onLinkTap,
  });

  static void show({
    required BuildContext context,
    required Translations t,
    VoidCallback? onDocumentTap,
    VoidCallback? onImageTap,
    VoidCallback? onLinkTap,
  }) {
    PickerBottomSheet.show(
      context: context,
      title: t.generate.presentationGenerate.attachFiles,
      child: AttachFileSheet(
        t: t,
        onDocumentTap: onDocumentTap ?? () {},
        onImageTap: onImageTap ?? () {},
        onLinkTap: onLinkTap ?? () {},
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Options
        ListTile(
          leading: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: colorScheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(LucideIcons.notepadText, color: colorScheme.primary),
          ),
          title: Text(t.generate.presentationGenerate.document),
          subtitle: Text(t.generate.presentationGenerate.documentFormats),
          onTap: () {
            Navigator.pop(context);
            onDocumentTap();
          },
        ),
        ListTile(
          leading: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.green.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(LucideIcons.image, color: Colors.green),
          ),
          title: Text(t.generate.presentationGenerate.image),
          subtitle: Text(t.generate.presentationGenerate.imageFormats),
          onTap: () {
            Navigator.pop(context);
            onImageTap();
          },
        ),
        ListTile(
          leading: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.orange.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(LucideIcons.link, color: Colors.orange),
          ),
          title: Row(
            children: [
              Text(t.generate.presentationGenerate.link),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.orange.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(
                    color: Colors.orange.withValues(alpha: 0.4),
                  ),
                ),
                child: const Text(
                  'Coming soon',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: Colors.orange,
                    height: 1.2,
                  ),
                ),
              ),
            ],
          ),
          subtitle: Text(t.generate.presentationGenerate.linkDescription),
          enabled: false,
          onTap: null,
        ),
      ],
    );
  }
}
