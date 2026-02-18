import 'package:AIPrimary/features/assignments/domain/entity/assignment_entity.dart';
import 'package:AIPrimary/features/assignments/domain/entity/context_entity.dart';
import 'package:AIPrimary/features/assignments/ui/widgets/context/context_display_card.dart';
import 'package:AIPrimary/features/assignments/ui/widgets/context/context_selector_sheet.dart';
import 'package:AIPrimary/shared/pods/translation_pod.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// Contexts (Reading Passages) tab for the assignment editor.
/// Provides a dedicated view to create, view, edit, and delete reading passages.
/// Matches the FE ContextsPanel design.
class ContextsTab extends ConsumerStatefulWidget {
  final AssignmentEntity assignment;
  final List<ContextEntity> contexts;
  final bool isEditMode;
  final void Function(ContextEntity context) onCreateContext;
  final void Function(ContextEntity context) onImportContext;
  final void Function(ContextEntity context) onEditContext;
  final void Function(String contextId) onDeleteContext;

  const ContextsTab({
    super.key,
    required this.assignment,
    required this.contexts,
    this.isEditMode = false,
    required this.onCreateContext,
    required this.onImportContext,
    required this.onEditContext,
    required this.onDeleteContext,
  });

  @override
  ConsumerState<ContextsTab> createState() => _ContextsTabState();
}

class _ContextsTabState extends ConsumerState<ContextsTab> {
  bool _showCreateForm = false;
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  final _authorController = TextEditingController();

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _authorController.dispose();
    super.dispose();
  }

  int _getReferencingQuestionCount(String contextId) {
    return widget.assignment.questions
        .where((q) => q.contextId == contextId)
        .length;
  }

  void _handleCreate() {
    final title = _titleController.text.trim();
    if (title.isEmpty) return;

    final localId =
        'ctx_${DateTime.now().millisecondsSinceEpoch}_${DateTime.now().microsecond}';

    widget.onCreateContext(
      ContextEntity(
        id: localId,
        title: title,
        content: _contentController.text,
        author: _authorController.text.trim().isEmpty
            ? null
            : _authorController.text.trim(),
      ),
    );

    _titleController.clear();
    _contentController.clear();
    _authorController.clear();
    setState(() => _showCreateForm = false);
  }

  void _handleCancelCreate() {
    _titleController.clear();
    _contentController.clear();
    _authorController.clear();
    setState(() => _showCreateForm = false);
  }

  void _showDeleteConfirmation(ContextEntity contextEntity) {
    final t = ref.read(translationsPod);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final refCount = _getReferencingQuestionCount(contextEntity.id);

    showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        icon: Icon(LucideIcons.trash2, color: colorScheme.error, size: 32),
        title: Text(t.assignments.context.deletePassageTitle),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              t.assignments.context.deletePassageMessage(
                title: contextEntity.title,
              ),
            ),
            if (refCount > 0) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.amber.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.amber.shade200),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      LucideIcons.triangleAlert,
                      size: 16,
                      color: Colors.amber.shade700,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        t.assignments.context.deletePassageWarning(
                          count: refCount,
                        ),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.amber.shade900,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(t.assignments.context.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: FilledButton.styleFrom(backgroundColor: colorScheme.error),
            child: Text(t.assignments.context.delete),
          ),
        ],
      ),
    ).then((confirmed) {
      if (confirmed == true) {
        widget.onDeleteContext(contextEntity.id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final t = ref.watch(translationsPod);

    return Container(
      color: colorScheme.surfaceContainerLowest,
      child: CustomScrollView(
        slivers: [
          // Header
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          LucideIcons.bookOpen,
                          size: 20,
                          color: Colors.blue.shade600,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          t.assignments.context.panelTitle,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onSurface,
                            letterSpacing: -0.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    t.assignments.context.panelDescription,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Add Button / Import Button / Inline Create Form
          if (widget.isEditMode)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: _showCreateForm
                    ? _buildCreateForm(theme, colorScheme, t)
                    : Row(
                        children: [
                          Expanded(
                            child: FilledButton.icon(
                              onPressed: () =>
                                  setState(() => _showCreateForm = true),
                              style: FilledButton.styleFrom(
                                minimumSize: const Size.fromHeight(44),
                                backgroundColor: colorScheme.primary,
                                foregroundColor: colorScheme.onPrimary,
                              ),
                              icon: const Icon(LucideIcons.plus, size: 18),
                              label: Text(
                                t.assignments.context.addReadingPassage,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () async {
                                final importedIds = widget.contexts
                                    .where((c) => c.sourceContextId != null)
                                    .map((c) => c.sourceContextId!)
                                    .toSet();
                                final selected =
                                    await ContextSelectorSheet.show(
                                      context,
                                      importedContextIds: importedIds,
                                      subjectFilter:
                                          widget.assignment.subject.apiValue,
                                    );
                                if (selected != null && mounted) {
                                  widget.onImportContext(selected);
                                }
                              },
                              style: OutlinedButton.styleFrom(
                                minimumSize: const Size.fromHeight(44),
                                foregroundColor: colorScheme.primary,
                                side: BorderSide(color: colorScheme.primary),
                              ),
                              icon: const Icon(LucideIcons.download, size: 18),
                              label: Text(
                                t.assignments.context.importFromLibrary,
                              ),
                            ),
                          ),
                        ],
                      ),
              ),
            ),

          // Context List or Empty State
          if (widget.contexts.isEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Container(
                  padding: const EdgeInsets.all(40),
                  decoration: BoxDecoration(
                    color: colorScheme.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: colorScheme.outlineVariant,
                      style: BorderStyle.solid,
                    ),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        LucideIcons.bookOpen,
                        size: 40,
                        color: colorScheme.onSurfaceVariant.withValues(
                          alpha: 0.5,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        t.assignments.context.emptyState,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            )
          else
            SliverList(
              delegate: SliverChildBuilderDelegate((context, index) {
                final ctx = widget.contexts[index];
                final refCount = _getReferencingQuestionCount(ctx.id);

                return Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: ContextDisplayCard(
                    context: ctx,
                    isEditMode: widget.isEditMode,
                    onEdit: widget.isEditMode
                        ? () => widget.onEditContext(ctx)
                        : null,
                    onDelete: widget.isEditMode
                        ? () => _showDeleteConfirmation(ctx)
                        : null,
                    badge: _buildRefCountBadge(refCount, theme, colorScheme, t),
                    readingPassageLabel: t.assignments.context.readingPassage,
                  ),
                );
              }, childCount: widget.contexts.length),
            ),

          // Bottom padding
          SliverToBoxAdapter(
            child: SizedBox(height: widget.isEditMode ? 190.0 : 88.0),
          ),
        ],
      ),
    );
  }

  Widget _buildRefCountBadge(
    int refCount,
    ThemeData theme,
    ColorScheme colorScheme,
    dynamic t,
  ) {
    if (refCount == 0) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        t.assignments.context.usedByQuestions(count: refCount),
        style: theme.textTheme.labelSmall?.copyWith(
          color: colorScheme.onPrimaryContainer,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildCreateForm(ThemeData theme, ColorScheme colorScheme, dynamic t) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title field
          Text(
            t.assignments.context.title,
            style: theme.textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          TextField(
            controller: _titleController,
            autofocus: true,
            decoration: InputDecoration(
              hintText: t.assignments.context.titleHint,
              border: const OutlineInputBorder(),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 10,
              ),
            ),
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 12),

          // Content field
          Text(
            t.assignments.context.content,
            style: theme.textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          TextField(
            controller: _contentController,
            maxLines: 5,
            minLines: 4,
            decoration: InputDecoration(
              hintText: t.assignments.context.contentHint,
              border: const OutlineInputBorder(),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 10,
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Author field
          Text(
            t.assignments.context.authorOptional,
            style: theme.textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          TextField(
            controller: _authorController,
            decoration: InputDecoration(
              hintText: t.assignments.context.authorHint,
              border: const OutlineInputBorder(),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 10,
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Action buttons
          Row(
            children: [
              FilledButton(
                onPressed: _titleController.text.trim().isEmpty
                    ? null
                    : _handleCreate,
                child: Text(t.assignments.context.create),
              ),
              const SizedBox(width: 8),
              TextButton(
                onPressed: _handleCancelCreate,
                child: Text(t.assignments.context.cancel),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
