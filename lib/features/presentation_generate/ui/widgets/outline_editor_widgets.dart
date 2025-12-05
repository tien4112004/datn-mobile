import 'package:datn_mobile/features/presentation_generate/domain/entity/outline_slide.dart';
import 'package:datn_mobile/features/presentation_generate/states/controller_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:markdown_editor_plus/markdown_editor_plus.dart';

/// Empty state view for when there are no slides to edit
class EmptyOutlineView extends StatelessWidget {
  const EmptyOutlineView({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            LucideIcons.fileText,
            size: 64,
            color: Theme.of(
              context,
            ).colorScheme.onSurface.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'No outline to edit',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Generate an outline first to start editing',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.5),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

/// List of outline slides with edit and delete functionality
class OutlineSlidesList extends ConsumerWidget {
  const OutlineSlidesList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final editingState = ref.watch(outlineEditingControllerProvider);

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: editingState.slides.length,
      itemBuilder: (context, index) {
        final slide = editingState.slides[index];
        return OutlineSlideCard(
          slide: slide,
          onEdit: () => _showSlideEditDialog(context, ref, slide),
          onDelete: () => _showDeleteConfirmation(context, ref, slide),
        );
      },
    );
  }

  void _showSlideEditDialog(
    BuildContext context,
    WidgetRef ref,
    OutlineSlide slide,
  ) {
    showDialog(
      context: context,
      builder: (context) => SlideEditDialog(slide: slide),
    );
  }

  void _showDeleteConfirmation(
    BuildContext context,
    WidgetRef ref,
    OutlineSlide slide,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Slide'),
        content: Text('Are you sure you want to delete "${slide.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              ref
                  .read(outlineEditingControllerProvider.notifier)
                  .removeSlide(slide.order);
              // Auto-save the changes
              final editingController = ref.read(
                outlineEditingControllerProvider.notifier,
              );
              final markdownOutline = editingController.getMarkdownOutline();
              ref
                  .read(presentationFormControllerProvider.notifier)
                  .setOutline(markdownOutline);
              Navigator.of(context).pop();
            },
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

/// Card displaying a single outline slide
class OutlineSlideCard extends StatelessWidget {
  final OutlineSlide slide;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const OutlineSlideCard({
    super.key,
    required this.slide,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).colorScheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${slide.order}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    slide.title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: onEdit,
                  icon: const Icon(LucideIcons.pen),
                  tooltip: 'Edit slide',
                ),
                IconButton(
                  onPressed: onDelete,
                  icon: const Icon(LucideIcons.trash),
                  tooltip: 'Delete slide',
                  color: Theme.of(context).colorScheme.error,
                ),
              ],
            ),
            if (slide.content.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                slide.content,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.7),
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Dialog for editing slide title and content
class SlideEditDialog extends ConsumerStatefulWidget {
  final OutlineSlide slide;

  const SlideEditDialog({super.key, required this.slide});

  @override
  ConsumerState<SlideEditDialog> createState() => _SlideEditDialogState();
}

class _SlideEditDialogState extends ConsumerState<SlideEditDialog> {
  late TextEditingController _titleController;
  late TextEditingController _contentController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.slide.title);
    _contentController = TextEditingController(text: widget.slide.content);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Edit Slide ${widget.slide.order}'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Slide Title',
                hintText: 'Enter slide title...',
              ),
            ),
            const SizedBox(height: 16),
            MarkdownAutoPreview(
              minLines: 5,
              maxLines: 10,
              controller: _contentController,
              decoration: const InputDecoration(
                labelText: 'Slide Title',
                hintText: 'Enter slide title...',
              ),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            ref
                .read(outlineEditingControllerProvider.notifier)
                .updateSlideContent(
                  widget.slide.order,
                  _titleController.text.trim(),
                  _contentController.text.trim(),
                );
            // Auto-save the changes
            final editingController = ref.read(
              outlineEditingControllerProvider.notifier,
            );
            final markdownOutline = editingController.getMarkdownOutline();
            ref
                .read(presentationFormControllerProvider.notifier)
                .setOutline(markdownOutline);
            Navigator.of(context).pop();
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}

/// Action bar with button to add new slides
class OutlineActionsBar extends ConsumerWidget {
  const OutlineActionsBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final editingState = ref.watch(outlineEditingControllerProvider);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        border: Border(
          top: BorderSide(color: Theme.of(context).dividerColor, width: 1),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () {
                // Add slide after the last slide
                final lastOrder = editingState.slides.isNotEmpty
                    ? editingState.slides.last.order
                    : 0;
                ref
                    .read(outlineEditingControllerProvider.notifier)
                    .addSlide(lastOrder);
                // Auto-save the changes
                Future.delayed(const Duration(milliseconds: 100), () {
                  final editingController = ref.read(
                    outlineEditingControllerProvider.notifier,
                  );
                  final markdownOutline = editingController
                      .getMarkdownOutline();
                  ref
                      .read(presentationFormControllerProvider.notifier)
                      .setOutline(markdownOutline);
                });
              },
              icon: const Icon(LucideIcons.plus),
              label: const Text('Add Slide'),
            ),
          ),
        ],
      ),
    );
  }
}
