import 'package:AIPrimary/features/assignments/domain/entity/context_entity.dart';
import 'package:AIPrimary/shared/pods/translation_pod.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// Full-screen page for editing context content.
///
/// Features:
/// - Title, content, and author editing
/// - Keyboard-aware scrolling
/// - Markdown content support
/// - Save/Cancel actions
/// - Unlink option in app bar menu
@RoutePage()
class ContextEditPage extends ConsumerStatefulWidget {
  final ContextEntity context;

  const ContextEditPage({super.key, required this.context});

  @override
  ConsumerState<ContextEditPage> createState() => _ContextEditPageState();
}

class _ContextEditPageState extends ConsumerState<ContextEditPage> {
  late TextEditingController _titleController;
  late TextEditingController _contentController;
  late TextEditingController _authorController;

  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.context.title);
    _contentController = TextEditingController(text: widget.context.content);
    _authorController = TextEditingController(
      text: widget.context.author ?? '',
    );

    _titleController.addListener(_onFieldChanged);
    _contentController.addListener(_onFieldChanged);
    _authorController.addListener(_onFieldChanged);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _authorController.dispose();
    super.dispose();
  }

  void _onFieldChanged() {
    final hasChanges =
        _titleController.text != widget.context.title ||
        _contentController.text != widget.context.content ||
        _authorController.text != (widget.context.author ?? '');

    if (hasChanges != _hasChanges) {
      setState(() => _hasChanges = hasChanges);
    }
  }

  ContextEntity _buildUpdatedContext() {
    return widget.context.copyWith(
      title: _titleController.text.trim(),
      content: _contentController.text,
      author: _authorController.text.trim().isEmpty
          ? null
          : _authorController.text.trim(),
    );
  }

  Future<bool> _onWillPop() async {
    if (!_hasChanges) return true;

    final t = ref.read(translationsPod);
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(t.assignments.context.discardChanges),
        content: Text(t.assignments.context.unsavedChangesMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(t.assignments.context.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: Text(t.assignments.context.discard),
          ),
        ],
      ),
    );

    return result ?? false;
  }

  void _onSave() {
    HapticFeedback.mediumImpact();
    final updatedContext = _buildUpdatedContext();
    context.router.maybePop(updatedContext);
  }

  void _onUnlink() async {
    final t = ref.read(translationsPod);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(t.assignments.context.unlinkContext),
        content: Text(t.assignments.context.unlinkMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(t.assignments.context.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: Text(t.assignments.context.unlink),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      context.router.maybePop('UNLINK');
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = ref.watch(translationsPod);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return PopScope(
      canPop: !_hasChanges,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final router = context.router;
        final shouldPop = await _onWillPop();
        if (shouldPop && mounted) {
          router.maybePop();
        }
      },
      child: Scaffold(
        backgroundColor: colorScheme.surface,
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(LucideIcons.arrowLeft),
            onPressed: () async {
              final router = context.router;
              if (_hasChanges) {
                final shouldPop = await _onWillPop();
                if (shouldPop && mounted) {
                  router.maybePop();
                }
              } else {
                router.maybePop();
              }
            },
          ),
          title: Row(
            children: [
              Icon(LucideIcons.bookOpen, size: 20, color: Colors.blue.shade600),
              const SizedBox(width: 8),
              Text(t.assignments.context.editReadingPassage),
            ],
          ),
          actions: [
            // Unlink action
            PopupMenuButton<String>(
              icon: const Icon(LucideIcons.ellipsisVertical),
              onSelected: (value) {
                if (value == 'unlink') {
                  _onUnlink();
                }
              },
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 'unlink',
                  child: Row(
                    children: [
                      Icon(
                        LucideIcons.unlink,
                        size: 18,
                        color: colorScheme.error,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        t.assignments.context.unlinkFromQuestion,
                        style: TextStyle(color: colorScheme.error),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title field
              Text(
                t.assignments.context.title,
                style: theme.textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _titleController,
                decoration: InputDecoration(
                  hintText: t.assignments.context.titleHint,
                  filled: true,
                  fillColor: colorScheme.surfaceContainerHighest,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: Colors.blue.shade400,
                      width: 2,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Content field
              Text(
                t.assignments.context.content,
                style: theme.textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                t.assignments.context.supportsMarkdown,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _contentController,
                maxLines: null,
                minLines: 10,
                keyboardType: TextInputType.multiline,
                decoration: InputDecoration(
                  hintText: t.assignments.context.contentHint,
                  filled: true,
                  fillColor: colorScheme.surfaceContainerHighest,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: Colors.blue.shade400,
                      width: 2,
                    ),
                  ),
                  contentPadding: const EdgeInsets.all(16),
                ),
              ),

              const SizedBox(height: 24),

              // Author field
              Text(
                t.assignments.context.authorOptional,
                style: theme.textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _authorController,
                decoration: InputDecoration(
                  hintText: t.assignments.context.authorHint,
                  prefixIcon: Icon(
                    LucideIcons.user,
                    size: 20,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  filled: true,
                  fillColor: colorScheme.surfaceContainerHighest,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: Colors.blue.shade400,
                      width: 2,
                    ),
                  ),
                ),
              ),

              // Bottom padding for keyboard
              const SizedBox(height: 100),
            ],
          ),
        ),
        bottomNavigationBar: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Cancel button
                Expanded(
                  child: OutlinedButton(
                    onPressed: () async {
                      final router = context.router;
                      if (_hasChanges) {
                        final shouldPop = await _onWillPop();
                        if (shouldPop && mounted) {
                          router.maybePop();
                        }
                      } else {
                        router.maybePop();
                      }
                    },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(t.assignments.context.cancel),
                  ),
                ),

                const SizedBox(width: 16),

                // Save button
                Expanded(
                  flex: 2,
                  child: FilledButton(
                    onPressed: _onSave,
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.blue.shade600,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(LucideIcons.check, size: 20),
                        const SizedBox(width: 8),
                        Text(t.assignments.context.saveChanges),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
