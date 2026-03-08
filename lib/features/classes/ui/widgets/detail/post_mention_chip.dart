import 'package:AIPrimary/core/theme/app_theme.dart';
import 'package:AIPrimary/features/classes/ui/widgets/detail/post_mention_parser.dart';
import 'package:AIPrimary/features/classes/ui/widgets/detail/post_peek_sheet.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// A thin inline chip rendered inside a comment when a post is mentioned via @.
///
/// Styled with [Themes.primaryColor] and truncates long preview titles.
/// Tapping opens [PostPeekSheet] to preview the referenced post.
class PostMentionChip extends StatelessWidget {
  final PostMentionSegment mention;

  const PostMentionChip({super.key, required this.mention});

  @override
  Widget build(BuildContext context) {
    const primaryColor = Themes.primaryColor;

    return GestureDetector(
      onTap: () => showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (_) => PostPeekSheet(mention: mention),
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
        decoration: BoxDecoration(
          color: primaryColor.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: primaryColor.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(LucideIcons.fileText, size: 11, color: primaryColor),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                mention.previewTitle,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: primaryColor,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
