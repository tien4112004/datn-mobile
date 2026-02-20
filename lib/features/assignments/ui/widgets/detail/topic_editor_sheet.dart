import 'package:AIPrimary/features/assignments/domain/entity/api_matrix_entity.dart';
import 'package:AIPrimary/shared/pods/translation_pod.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// Result from the topic editor bottom sheet.
enum TopicEditorAction { save, delete }

class TopicEditorResult {
  final TopicEditorAction action;
  final String? name;
  final bool? hasContext;

  const TopicEditorResult({required this.action, this.name, this.hasContext});
}

/// Bottom sheet for adding or editing a matrix topic.
///
/// Follows the same Material 3 patterns as MatrixCellEditorSheet.
class TopicEditorSheet extends ConsumerStatefulWidget {
  final MatrixDimensionTopic? existingTopic;
  final bool canDelete;

  const TopicEditorSheet({
    super.key,
    this.existingTopic,
    this.canDelete = false,
  });

  bool get isEditMode => existingTopic != null;

  @override
  ConsumerState<TopicEditorSheet> createState() => _TopicEditorSheetState();
}

class _TopicEditorSheetState extends ConsumerState<TopicEditorSheet> {
  late TextEditingController _nameController;
  late bool _hasContext;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(
      text: widget.existingTopic?.name ?? '',
    );
    _hasContext = widget.existingTopic?.hasContext ?? false;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _handleSave() {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;

    Navigator.pop(
      context,
      TopicEditorResult(
        action: TopicEditorAction.save,
        name: name,
        hasContext: _hasContext,
      ),
    );
  }

  void _handleDelete() {
    Navigator.pop(
      context,
      const TopicEditorResult(action: TopicEditorAction.delete),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final t = ref.watch(translationsPod);

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Drag handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Title
            Text(
              widget.isEditMode
                  ? t.assignments.detail.matrix.topic.editTopic
                  : t.assignments.detail.matrix.topic.addTopic,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 24),

            // Topic name field
            TextField(
              controller: _nameController,
              autofocus: !widget.isEditMode,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                labelText: t.assignments.detail.matrix.topic.topicName,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
              ),
              onSubmitted: (_) => _handleSave(),
            ),
            const SizedBox(height: 16),

            // Has context toggle
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(
                    LucideIcons.bookOpen,
                    size: 20,
                    color: _hasContext
                        ? Colors.blue.shade600
                        : colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          t.assignments.detail.matrix.topic.hasContext,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: colorScheme.onSurface,
                          ),
                        ),
                        Text(
                          t.assignments.detail.matrix.topic.hasContextHint,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Switch(
                    value: _hasContext,
                    onChanged: (value) => setState(() => _hasContext = value),
                  ),
                ],
              ),
            ),

            // Chapters display (read-only, informational)
            if (widget.existingTopic?.chapters != null &&
                widget.existingTopic!.chapters!.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text(
                t.assignments.detail.matrix.topic.chapters,
                style: theme.textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: widget.existingTopic!.chapters!
                    .map(
                      (chapter) => Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: colorScheme.primaryContainer.withValues(
                            alpha: 0.3,
                          ),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: colorScheme.primary.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Text(
                          chapter,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: colorScheme.onSurface,
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ],

            const SizedBox(height: 24),

            // Action buttons
            Row(
              children: [
                // Delete button (edit mode only, when canDelete)
                if (widget.isEditMode && widget.canDelete)
                  TextButton.icon(
                    onPressed: _handleDelete,
                    icon: Icon(
                      LucideIcons.trash2,
                      size: 16,
                      color: colorScheme.error,
                    ),
                    label: Text(
                      t.assignments.detail.matrix.topic.deleteTopic,
                      style: TextStyle(color: colorScheme.error),
                    ),
                  ),
                const Spacer(),
                // Cancel
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(t.assignments.detail.matrix.cancel),
                ),
                const SizedBox(width: 8),
                // Save
                FilledButton(
                  onPressed: _handleSave,
                  child: Text(t.assignments.detail.matrix.save),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Shows the topic editor bottom sheet.
/// Returns null if dismissed, or a [TopicEditorResult] with the action taken.
Future<TopicEditorResult?> showTopicEditorSheet({
  required BuildContext context,
  MatrixDimensionTopic? existingTopic,
  bool canDelete = false,
}) {
  return showModalBottomSheet<TopicEditorResult>(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (ctx) =>
        TopicEditorSheet(existingTopic: existingTopic, canDelete: canDelete),
  );
}
