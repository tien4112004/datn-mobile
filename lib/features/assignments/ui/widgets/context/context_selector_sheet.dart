import 'package:AIPrimary/features/assignments/domain/entity/context_entity.dart';
import 'package:AIPrimary/features/assignments/states/controller_provider.dart';
import 'package:AIPrimary/shared/pods/translation_pod.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// A bottom sheet for selecting contexts from the public library.
///
/// Features:
/// - Search bar for filtering contexts
/// - Paginated list with infinite scroll
/// - Context preview with title and content snippet
/// - Touch-friendly list items (56-72dp height)
///
/// Usage:
/// ```dart
/// final context = await ContextSelectorSheet.show(context);
/// ```
class ContextSelectorSheet {
  ContextSelectorSheet._();

  /// Shows the context selector as a modal bottom sheet.
  ///
  /// [importedContextIds] — IDs of library contexts already imported into
  /// the assignment. These will be shown with an "Added" badge.
  static Future<ContextEntity?> show(
    BuildContext context, {
    Set<String> importedContextIds = const {},
  }) {
    return showModalBottomSheet<ContextEntity>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.75,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) => _ContextSelectorContent(
          scrollController: scrollController,
          importedContextIds: importedContextIds,
        ),
      ),
    );
  }
}

/// Content widget for the context selector bottom sheet.
class _ContextSelectorContent extends ConsumerStatefulWidget {
  final ScrollController scrollController;
  final Set<String> importedContextIds;

  const _ContextSelectorContent({
    required this.scrollController,
    this.importedContextIds = const {},
  });

  @override
  ConsumerState<_ContextSelectorContent> createState() =>
      _ContextSelectorContentState();
}

class _ContextSelectorContentState
    extends ConsumerState<_ContextSelectorContent> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    widget.scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (widget.scrollController.position.pixels >=
        widget.scrollController.position.maxScrollExtent - 200) {
      ref.read(contextsControllerProvider.notifier).loadNextPage();
    }
  }

  void _onSearch(String query) {
    ref
        .read(contextsControllerProvider.notifier)
        .setSearch(query.isEmpty ? null : query);
  }

  @override
  Widget build(BuildContext context) {
    final t = ref.watch(translationsPod);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final contextsAsync = ref.watch(contextsControllerProvider);

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
                  t.assignments.context.selectReadingPassage,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          // Search bar
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
                          _onSearch('');
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
              onChanged: _onSearch,
            ),
          ),

          const SizedBox(height: 8),

          // Context list
          Expanded(
            child: contextsAsync.when(
              data: (result) {
                if (result.contexts.isEmpty) {
                  return _buildEmptyState(theme, colorScheme, t);
                }

                return ListView.builder(
                  controller: widget.scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  itemCount:
                      result.contexts.length +
                      (result.pagination.hasMore ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index >= result.contexts.length) {
                      return const Padding(
                        padding: EdgeInsets.all(16),
                        child: Center(
                          child: SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        ),
                      );
                    }

                    final contextEntity = result.contexts[index];
                    final isImported = widget.importedContextIds.contains(
                      contextEntity.id,
                    );
                    return _ContextListItem(
                      context: contextEntity,
                      onTap: () => Navigator.of(context).pop(contextEntity),
                      untitledLabel: t.assignments.context.untitledContext,
                      isImported: isImported,
                      addedLabel: t.assignments.context.added,
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) =>
                  _buildErrorState(theme, colorScheme, error, t),
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
          Text(
            t.assignments.context.noContextsFound,
            style: theme.textTheme.titleMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            t.assignments.context.tryDifferentSearch,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(
    ThemeData theme,
    ColorScheme colorScheme,
    Object error,
    dynamic t,
  ) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(LucideIcons.circleAlert, size: 48, color: colorScheme.error),
          const SizedBox(height: 16),
          Text(
            t.assignments.context.failedToLoad,
            style: theme.textTheme.titleMedium?.copyWith(
              color: colorScheme.error,
            ),
          ),
          const SizedBox(height: 8),
          TextButton.icon(
            onPressed: () =>
                ref.read(contextsControllerProvider.notifier).refresh(),
            icon: const Icon(LucideIcons.refreshCw, size: 18),
            label: Text(t.assignments.context.retry),
          ),
        ],
      ),
    );
  }
}

/// Individual context list item with title and content preview.
class _ContextListItem extends StatelessWidget {
  final ContextEntity context;
  final VoidCallback onTap;
  final String? untitledLabel;
  final bool isImported;
  final String? addedLabel;

  const _ContextListItem({
    required this.context,
    required this.onTap,
    this.untitledLabel,
    this.isImported = false,
    this.addedLabel,
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

    return Opacity(
      opacity: isImported ? 0.6 : 1.0,
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        elevation: 0,
        color: colorScheme.surfaceContainerLow,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: colorScheme.outlineVariant.withValues(alpha: 0.5),
          ),
        ),
        child: InkWell(
          onTap: isImported ? null : onTap,
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
                                  color: colorScheme.onSurfaceVariant
                                      .withValues(alpha: 0.7),
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

                // Added badge or arrow
                if (isImported)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          LucideIcons.check,
                          size: 14,
                          color: Colors.green.shade700,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          addedLabel ?? 'Added',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: Colors.green.shade700,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  )
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
      ),
    );
  }
}
