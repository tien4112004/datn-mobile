import 'package:datn_mobile/core/theme/app_theme.dart';
import 'package:datn_mobile/i18n/strings.g.dart';
import 'package:datn_mobile/shared/utils/snackbar_utils.dart';
import 'package:flutter/material.dart';

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
    showModalBottomSheet(
      context: context,
      backgroundColor: context.surfaceColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (bottomSheetContext) => AttachFileSheet(
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
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 12),
        // Handle
        Container(
          width: 40,
          height: 4,
          decoration: BoxDecoration(
            color: context.dividerColor,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(height: 16),
        // Title
        Text(
          t.generate.presentationGenerate.attachFiles,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: context.isDarkMode ? Colors.white : Colors.grey[900],
          ),
        ),
        const SizedBox(height: 8),
        // Options
        ListTile(
          leading: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.blue.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.description_outlined, color: Colors.blue),
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
            child: const Icon(Icons.image_outlined, color: Colors.green),
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
            child: const Icon(Icons.link_rounded, color: Colors.orange),
          ),
          title: Text(t.generate.presentationGenerate.link),
          subtitle: Text(t.generate.presentationGenerate.linkDescription),
          onTap: () {
            Navigator.pop(context);
            onLinkTap();
          },
        ),
        SizedBox(height: MediaQuery.of(context).padding.bottom + 16),
      ],
    );
  }
}
