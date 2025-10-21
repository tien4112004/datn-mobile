import 'package:datn_mobile/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:datn_mobile/shared/pods/translation_pod.dart';

class RecentDocumentsSection extends ConsumerWidget {
  const RecentDocumentsSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(translationsPod);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          t.recentDocuments,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 180,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              _buildDocumentCard(
                context,
                fileName: 'Project Proposal.pdf',
                description: 'Updated 2 hours ago',
              ),
              const SizedBox(width: 12),
              _buildDocumentCard(
                context,
                fileName: 'Presentation Slides.pptx',
                description: 'Updated yesterday',
              ),
              const SizedBox(width: 12),
              _buildDocumentCard(
                context,
                fileName: 'Meeting Notes.docx',
                description: 'Updated 3 days ago',
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDocumentCard(
    BuildContext context, {
    required String fileName,
    required String description,
  }) {
    return InkWell(
      onTap: () {
        // TODO: Navigate to document detail page
        debugPrint('Document tapped: $fileName');
      },
      borderRadius: Themes.boxRadius,
      child: Container(
        width: 200,
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: Themes.boxRadius,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 16:9 Thumbnail
            Container(
              width: 200,
              height: 200 * 9 / 16, // 16:9 aspect ratio
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(Themes.boxRadiusValue),
                  topRight: Radius.circular(Themes.boxRadiusValue),
                ),
              ),
              child: Center(
                child: Icon(
                  LucideIcons.fileText,
                  color: Colors.grey.shade400,
                  size: 48,
                ),
              ),
            ),
            // File name and description
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    fileName,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
