import 'package:AIPrimary/features/generate/ui/widgets/shared/picker_bottom_sheet.dart';
import 'package:AIPrimary/i18n/strings.g.dart';
import 'package:AIPrimary/shared/utils/snackbar_utils.dart';
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

  static void show({required BuildContext context, required Translations t}) {
    PickerBottomSheet.show(
      context: context,
      title: t.generate.presentationGenerate.attachFiles,
      child: AttachFileSheet(
        t: t,
        onDocumentTap: () {
          SnackbarUtils.showInfo(
            context,
            t.generate.presentationGenerate.documentPickerComingSoon,
          );
        },
        onImageTap: () {
          SnackbarUtils.showInfo(
            context,
            t.generate.presentationGenerate.imagePickerComingSoon,
          );
        },
        onLinkTap: () {
          SnackbarUtils.showInfo(
            context,
            t.generate.presentationGenerate.linkInputComingSoon,
          );
        },
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
          title: Text(t.generate.presentationGenerate.link),
          subtitle: Text(t.generate.presentationGenerate.linkDescription),
          onTap: () {
            Navigator.pop(context);
            onLinkTap();
          },
        ),
      ],
    );
  }
}
