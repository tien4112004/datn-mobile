import 'package:AIPrimary/core/theme/app_theme.dart';
import 'package:AIPrimary/features/classes/domain/entity/post_entity.dart';
import 'package:AIPrimary/features/classes/states/posts_provider.dart';
import 'package:AIPrimary/features/classes/ui/widgets/detail/post_mention_parser.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// Bottom sheet that lists posts in a class so the user can pick one to
/// reference via @-mention in a comment.
///
/// Returns a [PostMentionSegment] via [Navigator.pop] on selection, or null
/// when dismissed without choosing.
class PostPickerSheet extends ConsumerStatefulWidget {
  final String classId;

  const PostPickerSheet({super.key, required this.classId});

  @override
  ConsumerState<PostPickerSheet> createState() => _PostPickerSheetState();
}

class _PostPickerSheetState extends ConsumerState<PostPickerSheet> {
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<PostEntity> _filter(List<PostEntity> posts) {
    if (_query.isEmpty) return posts;
    final q = _query.toLowerCase();
    return posts.where((p) => p.content.toLowerCase().contains(q)).toList();
  }

  void _onSelect(PostEntity post) {
    final previewTitle = post.content
        .replaceAll('\n', ' ')
        .replaceAll('\r', '')
        .trim();

    Navigator.pop(
      context,
      PostMentionSegment(
        classId: widget.classId,
        postId: post.id,
        previewTitle: previewTitle,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final primaryColor = Themes.primaryColor;
    final postsAsync = ref.watch(postsControllerProvider(widget.classId));

    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.4,
      maxChildSize: 0.9,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Drag handle
              Center(
                child: Container(
                  margin: const EdgeInsets.only(top: 12, bottom: 8),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: colorScheme.outlineVariant,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: primaryColor.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        LucideIcons.atSign,
                        size: 16,
                        color: primaryColor,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'Mention a post',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(LucideIcons.x, size: 18),
                      visualDensity: VisualDensity.compact,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ],
                ),
              ),

              // Search field
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                child: TextField(
                  controller: _searchController,
                  autofocus: true,
                  onChanged: (v) => setState(() => _query = v),
                  decoration: InputDecoration(
                    hintText: 'Search posts…',
                    prefixIcon: const Icon(LucideIcons.search, size: 18),
                    suffixIcon: _query.isNotEmpty
                        ? IconButton(
                            icon: const Icon(LucideIcons.x, size: 16),
                            onPressed: () {
                              _searchController.clear();
                              setState(() => _query = '');
                            },
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: colorScheme.outlineVariant),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: colorScheme.outlineVariant),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: colorScheme.primary),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    isDense: true,
                  ),
                ),
              ),

              Divider(height: 1, color: colorScheme.outlineVariant),

              // Posts list
              Expanded(
                child: postsAsync.when(
                  data: (posts) {
                    final filtered = _filter(posts);

                    if (filtered.isEmpty) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(32),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                LucideIcons.searchX,
                                size: 36,
                                color: colorScheme.onSurfaceVariant.withValues(
                                  alpha: 0.5,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                _query.isEmpty
                                    ? 'No posts in this class yet'
                                    : 'No posts match "$_query"',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: colorScheme.onSurfaceVariant,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      );
                    }

                    return ListView.separated(
                      controller: scrollController,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      itemCount: filtered.length,
                      separatorBuilder: (context, index) => Divider(
                        height: 1,
                        indent: 56,
                        color: colorScheme.outlineVariant,
                      ),
                      itemBuilder: (context, index) {
                        final post = filtered[index];
                        return _PostPickerItem(
                          post: post,
                          query: _query,
                          primaryColor: primaryColor,
                          onTap: () => _onSelect(post),
                        );
                      },
                    );
                  },
                  loading: () => const Center(
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  error: (e, _) => Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text(
                        'Failed to load posts',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colorScheme.error,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _PostPickerItem extends StatelessWidget {
  final PostEntity post;
  final String query;
  final Color primaryColor;
  final VoidCallback onTap;

  const _PostPickerItem({
    required this.post,
    required this.query,
    required this.primaryColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: primaryColor.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(LucideIcons.fileText, size: 16, color: primaryColor),
            ),
            const SizedBox(width: 12),

            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Author
                  Text(
                    post.authorName,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 2),
                  // Post content preview with highlight
                  _buildHighlightedText(
                    context,
                    post.content,
                    query,
                    theme.textTheme.bodyMedium,
                    primaryColor,
                  ),
                ],
              ),
            ),

            const SizedBox(width: 8),
            Icon(
              LucideIcons.cornerDownLeft,
              size: 14,
              color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHighlightedText(
    BuildContext context,
    String text,
    String query,
    TextStyle? baseStyle,
    Color highlightColor,
  ) {
    // Flatten content for display.
    final flat = text.replaceAll('\n', ' ').trim();

    if (query.isEmpty) {
      return Text(
        flat,
        style: baseStyle,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      );
    }

    final lower = flat.toLowerCase();
    final qLower = query.toLowerCase();
    final matchIndex = lower.indexOf(qLower);

    if (matchIndex == -1) {
      return Text(
        flat,
        style: baseStyle,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      );
    }

    return RichText(
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      text: TextSpan(
        style: baseStyle,
        children: [
          if (matchIndex > 0) TextSpan(text: flat.substring(0, matchIndex)),
          TextSpan(
            text: flat.substring(matchIndex, matchIndex + query.length),
            style: TextStyle(
              color: highlightColor,
              fontWeight: FontWeight.w600,
              backgroundColor: highlightColor.withValues(alpha: 0.1),
            ),
          ),
          if (matchIndex + query.length < flat.length)
            TextSpan(text: flat.substring(matchIndex + query.length)),
        ],
      ),
    );
  }
}
