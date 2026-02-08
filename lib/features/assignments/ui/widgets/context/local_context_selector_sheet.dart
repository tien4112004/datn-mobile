import 'package:AIPrimary/features/assignments/domain/entity/context_entity.dart';
import 'package:AIPrimary/shared/pods/translation_pod.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// A bottom sheet for selecting from assignment-local contexts only.
///
/// Unlike [ContextSelectorSheet] which fetches from the public API,
/// this selector works with a pre-loaded list of contexts that have
/// already been imported into the assignment. No API calls or pagination.
///
/// Usage:
/// ```dart
/// final selected = await LocalContextSelectorSheet.show(
///   context,
///   contexts: assignmentContexts,
///   currentContextId: question.contextId,
/// );
/// ```
class LocalContextSelectorSheet {
  LocalContextSelectorSheet._();

  /// Shows the local context selector as a modal bottom sheet.
  static Future<ContextEntity?> show(
    BuildContext context, {
    required List<ContextEntity> contexts,
    String? currentContextId,
  }) {
    return showModalBottomSheet<ContextEntity>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.65,
        minChildSize: 0.4,
        maxChildSize: 0.9,
        builder: (context, scrollController) => _LocalContextSelectorContent(
          scrollController: scrollController,
          contexts: contexts,
          currentContextId: currentContextId,
        ),
      ),
    );
  }
}

class _LocalContextSelectorContent extends ConsumerStatefulWidget {
  final ScrollController scrollController;
  final List<ContextEntity> contexts;
  final String? currentContextId;

  const _LocalContextSelectorContent({
    required this.scrollController,
    required this.contexts,
    this.currentContextId,
  });

  @override
  ConsumerState<_LocalContextSelectorContent> createState() =>
      _LocalContextSelectorContentState();
}

class _LocalContextSelectorContentState
    extends ConsumerState<_LocalContextSelectorContent> {
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<ContextEntity> get _filteredContexts {
    if (_searchQuery.isEmpty) return widget.contexts;
    final q = _searchQuery.toLowerCase();
    return widget.contexts.where((ctx) {
      return ctx.title.toLowerCase().contains(q) ||
          ctx.content.toLowerCase().contains(q);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final t = ref.watch(translationsPod);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final filtered = _filteredContexts;

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
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(
                  LucideIcons.bookOpen,
                  size: 24,
                  color: Colors.blue.shade600,
                ),
                const SizedBox(width: 12),
                Text(
                  t.assignments.context.selectLocalPassage,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          // Search bar (only show if there are contexts to search)
          if (widget.contexts.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: t.assignments.context.searchContexts,
                  prefixIcon: const Icon(LucideIcons.search, size: 20),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(LucideIcons.x, size: 18),
                          onPressed: () {
                            _searchController.clear();
                            setState(() => _searchQuery = '');
                          },
                        )
                      : null,
                  filled: true,
                  fillColor: colorScheme.surfaceContainerHighest,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
                onChanged: (query) => setState(() => _searchQuery = query),
              ),
            ),

          const SizedBox(height: 8),

          // Context list
          Expanded(
            child: filtered.isEmpty
                ? _buildEmptyState(theme, colorScheme, t)
                : ListView.builder(
                    controller: widget.scrollController,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final contextEntity = filtered[index];
                      final isSelected =
                          contextEntity.id == widget.currentContextId;

                      return _LocalContextListItem(
                        context: contextEntity,
                        isSelected: isSelected,
                        onTap: () => Navigator.of(context).pop(contextEntity),
                        untitledLabel: t.assignments.context.untitledContext,
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme, ColorScheme colorScheme, dynamic t) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            LucideIcons.bookX,
            size: 48,
            color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              t.assignments.context.noLocalPassages,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}

/// Individual context list item with selection indicator.
class _LocalContextListItem extends StatelessWidget {
  final ContextEntity context;
  final bool isSelected;
  final VoidCallback onTap;
  final String? untitledLabel;

  const _LocalContextListItem({
    required this.context,
    required this.isSelected,
    required this.onTap,
    this.untitledLabel,
  });

  String _getPreviewText() {
    final content = context.content;
    if (content.length <= 100) return content;
    return '${content.substring(0, 100)}...';
  }

  @override
  Widget build(BuildContext buildContext) {
    final theme = Theme.of(buildContext);
    final colorScheme = theme.colorScheme;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      elevation: 0,
      color: isSelected
          ? colorScheme.primaryContainer.withValues(alpha: 0.5)
          : colorScheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isSelected
              ? colorScheme.primary
              : colorScheme.outlineVariant.withValues(alpha: 0.5),
          width: isSelected ? 2 : 1,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Book icon
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: isSelected
                      ? colorScheme.primary.withValues(alpha: 0.15)
                      : Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  LucideIcons.bookOpen,
                  size: 20,
                  color: isSelected
                      ? colorScheme.primary
                      : Colors.blue.shade600,
                ),
              ),

              const SizedBox(width: 12),

              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.title.isNotEmpty
                          ? context.title
                          : (untitledLabel ?? 'Untitled Context'),
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurface,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _getPreviewText(),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        height: 1.4,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (context.author != null &&
                        context.author!.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            LucideIcons.user,
                            size: 12,
                            color: colorScheme.onSurfaceVariant.withValues(
                              alpha: 0.7,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              context.author!,
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: colorScheme.onSurfaceVariant.withValues(
                                  alpha: 0.7,
                                ),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),

              // Selection indicator
              if (isSelected)
                Icon(LucideIcons.check, size: 20, color: colorScheme.primary)
              else
                Icon(
                  LucideIcons.chevronRight,
                  size: 20,
                  color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
