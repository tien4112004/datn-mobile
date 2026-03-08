import 'package:AIPrimary/features/classes/ui/widgets/detail/post_mention_chip.dart';
import 'package:AIPrimary/features/classes/ui/widgets/detail/post_mention_parser.dart';
import 'package:flutter/material.dart';

/// Renders comment content as rich text, replacing any embedded post mention
/// tokens with tappable [PostMentionChip] widgets inline with plain text.
class RichCommentContent extends StatelessWidget {
  final String content;
  final TextStyle? style;

  const RichCommentContent({super.key, required this.content, this.style});

  @override
  Widget build(BuildContext context) {
    final effectiveStyle =
        style ?? Theme.of(context).textTheme.bodyMedium ?? const TextStyle();

    final segments = PostMentionParser.parse(content);

    // Fast path: no mention tokens — render plain text directly.
    if (segments.length == 1 && segments.first is TextSegment) {
      return Text((segments.first as TextSegment).text, style: effectiveStyle);
    }

    final spans = <InlineSpan>[];

    for (final segment in segments) {
      switch (segment) {
        case TextSegment(:final text):
          spans.add(TextSpan(text: text, style: effectiveStyle));

        case PostMentionSegment(
          :final classId,
          :final postId,
          :final previewTitle,
        ):
          spans.add(
            WidgetSpan(
              alignment: PlaceholderAlignment.middle,
              child: Padding(
                // Small horizontal breathing room around the chip.
                padding: const EdgeInsets.symmetric(horizontal: 2),
                child: PostMentionChip(
                  mention: PostMentionSegment(
                    classId: classId,
                    postId: postId,
                    previewTitle: previewTitle,
                  ),
                ),
              ),
            ),
          );
      }
    }

    return RichText(text: TextSpan(children: spans));
  }
}
