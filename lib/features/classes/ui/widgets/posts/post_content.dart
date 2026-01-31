import 'package:AIPrimary/shared/pods/translation_pod.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:markdown_editor_plus/markdown_editor_plus.dart';

/// Content section of a post card with markdown preview
class PostContent extends ConsumerStatefulWidget {
  final String content;

  const PostContent({super.key, required this.content});

  @override
  ConsumerState<PostContent> createState() => _PostContentState();
}

class _PostContentState extends ConsumerState<PostContent> {
  late TextEditingController _markdownController;

  @override
  void initState() {
    super.initState();
    _markdownController = TextEditingController(text: widget.content);
  }

  @override
  void dispose() {
    _markdownController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = ref.watch(translationsPod);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: MarkdownAutoPreview(
        controller: _markdownController,
        decoration: InputDecoration(
          labelText: t.generate.outlineEditor.slideTitle,
          hintText: t.generate.outlineEditor.enterSlideTitle,
        ),
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
        ),
      ),
    );
  }
}
