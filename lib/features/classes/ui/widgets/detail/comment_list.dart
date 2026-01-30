import 'package:AIPrimary/features/classes/domain/entity/comment_entity.dart';
import 'package:AIPrimary/features/classes/ui/widgets/detail/comment_card.dart';
import 'package:flutter/material.dart';

/// List widget displaying all comments
class CommentList extends StatelessWidget {
  final List<CommentEntity> comments;

  const CommentList({super.key, required this.comments});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.zero,
      itemCount: comments.length,
      separatorBuilder: (context, index) =>
          Divider(height: 1, indent: 56, color: colorScheme.outlineVariant),
      itemBuilder: (context, index) {
        final comment = comments[index];
        return CommentCard(key: ValueKey(comment.id), comment: comment);
      },
    );
  }
}
