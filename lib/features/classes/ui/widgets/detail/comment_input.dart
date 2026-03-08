import 'package:AIPrimary/core/theme/app_theme.dart';
import 'package:AIPrimary/features/classes/states/posts_provider.dart';
import 'package:AIPrimary/features/classes/ui/widgets/detail/post_mention_parser.dart';
import 'package:AIPrimary/features/classes/ui/widgets/detail/post_picker_sheet.dart';
import 'package:AIPrimary/shared/pods/translation_pod.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// Input field for adding comments to a post.
///
/// Supports @-mention of other posts: typing `@` opens [PostPickerSheet].
/// Selected posts appear as removable preview chips above the text field —
/// the raw text field stays clean. On send, the typed text and mention URL
/// tokens are combined into the final comment content.
class CommentInput extends ConsumerStatefulWidget {
  final String postId;
  final String classId;
  final bool enabled;

  const CommentInput({
    super.key,
    required this.postId,
    required this.classId,
    this.enabled = true,
  });

  @override
  ConsumerState<CommentInput> createState() => _CommentInputState();
}

class _CommentInputState extends ConsumerState<CommentInput> {
  final _controller = TextEditingController();
  final List<PostMentionSegment> _mentions = [];
  bool _isSending = false;
  bool _pickerOpen = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onControllerChanged);
  }

  @override
  void dispose() {
    _controller.removeListener(_onControllerChanged);
    _controller.dispose();
    super.dispose();
  }

  void _onControllerChanged() {
    if (_pickerOpen) return;
    final text = _controller.text;
    final cursor = _controller.selection.baseOffset;
    if (cursor > 0 && cursor <= text.length && text[cursor - 1] == '@') {
      _showPostPicker(atOffset: cursor - 1);
    }
  }

  Future<void> _showPostPicker({required int atOffset}) async {
    if (_pickerOpen) return;
    setState(() => _pickerOpen = true);

    final mention = await showModalBottomSheet<PostMentionSegment>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => PostPickerSheet(classId: widget.classId),
    );

    if (!mounted) return;
    setState(() => _pickerOpen = false);

    // Remove the `@` character that triggered the picker regardless of result.
    final text = _controller.text;
    final safeOffset = atOffset.clamp(0, text.length);
    final afterAt = _controller.selection.baseOffset.clamp(
      safeOffset,
      text.length,
    );
    final cleaned = text.substring(0, safeOffset) + text.substring(afterAt);
    _controller.value = TextEditingValue(
      text: cleaned,
      selection: TextSelection.collapsed(offset: safeOffset),
    );

    if (mention == null) return;

    // Prevent duplicate mentions of the same post.
    if (_mentions.any((m) => m.postId == mention.postId)) return;

    setState(() => _mentions.add(mention));
  }

  void _removeMention(PostMentionSegment mention) {
    setState(() => _mentions.removeWhere((m) => m.postId == mention.postId));
  }

  Future<void> _sendComment() async {
    final typedText = _controller.text.trim();
    if (typedText.isEmpty && _mentions.isEmpty) return;

    // Build final content: user text + mention URL tokens.
    final tokens = _mentions
        .map(
          (m) => PostMentionParser.buildMentionToken(
            classId: m.classId,
            postId: m.postId,
            previewTitle: m.previewTitle,
          ),
        )
        .join(' ');

    final content = [
      typedText,
      if (tokens.isNotEmpty) tokens,
    ].where((s) => s.isNotEmpty).join(' ');

    final t = ref.read(translationsPod);
    setState(() => _isSending = true);
    HapticFeedback.mediumImpact();

    try {
      await ref
          .read(createCommentControllerProvider.notifier)
          .createComment(postId: widget.postId, content: content);

      if (mounted) {
        _controller.clear();
        setState(() => _mentions.clear());
        FocusScope.of(context).unfocus();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(t.classes.comments.postError(error: e.toString())),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final t = ref.watch(translationsPod);

    return Semantics(
      label: t.classes.comments.inputLabel,
      textField: true,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: colorScheme.outlineVariant)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Mention chips row
            if (_mentions.isNotEmpty) ...[
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    for (int i = 0; i < _mentions.length; i++) ...[
                      if (i > 0) const SizedBox(width: 8),
                      _MentionInputChip(
                        mention: _mentions[i],
                        onRemove: () => _removeMention(_mentions[i]),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 10),
            ],

            // Text field + send button
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    enabled: widget.enabled && !_isSending,
                    maxLines: 3,
                    minLines: 1,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: InputDecoration(
                      hintText: widget.enabled
                          ? t.classes.comments.inputHint
                          : t.classes.comments.inputDisabledHint,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: colorScheme.outlineVariant,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: colorScheme.outlineVariant,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: colorScheme.primary),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Semantics(
                  label: t.classes.comments.sendLabel,
                  button: true,
                  enabled: widget.enabled && !_isSending,
                  child: IconButton.filled(
                    onPressed: widget.enabled && !_isSending
                        ? _sendComment
                        : null,
                    icon: _isSending
                        ? SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: colorScheme.onPrimary,
                            ),
                          )
                        : const Icon(LucideIcons.send, size: 20),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// A removable mention chip shown above the comment input after a post is
/// selected via @-mention. Displays the post content preview (truncated)
/// with a small close button.
class _MentionInputChip extends StatelessWidget {
  final PostMentionSegment mention;
  final VoidCallback onRemove;

  const _MentionInputChip({required this.mention, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    const primaryColor = Themes.primaryColor;
    final theme = Theme.of(context);

    return Container(
      constraints: const BoxConstraints(maxWidth: 220),
      padding: const EdgeInsets.only(left: 8, right: 4, top: 5, bottom: 5),
      decoration: BoxDecoration(
        color: primaryColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: primaryColor.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(LucideIcons.fileText, size: 13, color: primaryColor),
          const SizedBox(width: 5),
          Flexible(
            child: Text(
              mention.previewTitle,
              style: theme.textTheme.labelSmall?.copyWith(
                color: primaryColor,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 4),
          GestureDetector(
            onTap: onRemove,
            child: Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                color: primaryColor.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.close, size: 10, color: primaryColor),
            ),
          ),
        ],
      ),
    );
  }
}
