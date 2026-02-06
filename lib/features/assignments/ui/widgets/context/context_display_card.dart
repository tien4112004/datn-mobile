import 'package:AIPrimary/features/assignments/domain/entity/context_entity.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// Material 3 collapsible context display card (read-only).
///
/// Features:
/// - Blue left border accent (matching FE design)
/// - Smooth expand/collapse animation
/// - Plain text preview when collapsed, full text when expanded
/// - Author display (optional)
/// - Touch-friendly (44dp minimum tap targets)
/// - Default collapsed for mobile (saves screen space)
class ContextDisplayCard extends StatefulWidget {
  final ContextEntity context;
  final bool initiallyExpanded;
  final VoidCallback? onEdit;
  final VoidCallback? onUnlink;
  final bool isEditMode;

  const ContextDisplayCard({
    super.key,
    required this.context,
    this.initiallyExpanded = false,
    this.onEdit,
    this.onUnlink,
    this.isEditMode = false,
  });

  @override
  State<ContextDisplayCard> createState() => _ContextDisplayCardState();
}

class _ContextDisplayCardState extends State<ContextDisplayCard>
    with SingleTickerProviderStateMixin {
  late bool _isExpanded;
  late AnimationController _animationController;
  late Animation<double> _rotationAnimation;

  static const int _previewMaxLines = 3;
  static const int _previewMaxChars = 150;

  @override
  void initState() {
    super.initState();
    _isExpanded = widget.initiallyExpanded;
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _rotationAnimation = Tween<double>(begin: 0.0, end: 0.5).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    if (_isExpanded) {
      _animationController.value = 1.0;
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggleExpanded() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }

  String _getPreviewText() {
    final content = widget.context.content;
    if (content.length <= _previewMaxChars) return content;
    return '${content.substring(0, _previewMaxChars)}...';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border(left: BorderSide(color: Colors.blue.shade400, width: 4)),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          topRight: Radius.circular(12),
          bottomRight: Radius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(theme, colorScheme),
            AnimatedSize(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              child: _isExpanded
                  ? _buildExpandedContent(theme, colorScheme)
                  : _buildCollapsedPreview(theme, colorScheme),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme, ColorScheme colorScheme) {
    return InkWell(
      onTap: _toggleExpanded,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.context.title.isNotEmpty
                        ? widget.context.title
                        : 'Reading Passage',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: Colors.blue.shade900,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (widget.context.author != null &&
                      widget.context.author!.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Icon(
                          LucideIcons.user,
                          size: 12,
                          color: colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            widget.context.author!,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
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
            if (widget.isEditMode) ...[
              if (widget.onEdit != null)
                IconButton(
                  icon: Icon(
                    LucideIcons.pencil,
                    size: 18,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  onPressed: widget.onEdit,
                  constraints: const BoxConstraints(
                    minWidth: 44,
                    minHeight: 44,
                  ),
                ),
              if (widget.onUnlink != null)
                IconButton(
                  icon: Icon(
                    LucideIcons.unlink,
                    size: 18,
                    color: colorScheme.error,
                  ),
                  onPressed: widget.onUnlink,
                  constraints: const BoxConstraints(
                    minWidth: 44,
                    minHeight: 44,
                  ),
                ),
            ],
            RotationTransition(
              turns: _rotationAnimation,
              child: Icon(
                LucideIcons.chevronDown,
                size: 20,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCollapsedPreview(ThemeData theme, ColorScheme colorScheme) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
      child: Text(
        _getPreviewText(),
        style: theme.textTheme.bodyMedium?.copyWith(
          color: colorScheme.onSurfaceVariant,
          height: 1.5,
        ),
        maxLines: _previewMaxLines,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget _buildExpandedContent(ThemeData theme, ColorScheme colorScheme) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Read-only content text
          SelectableText(
            widget.context.content,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurface,
              height: 1.6,
            ),
          ),
          if (widget.context.author != null &&
              widget.context.author!.isNotEmpty) ...[
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                '— ${widget.context.author}',
                style: theme.textTheme.bodySmall?.copyWith(
                  fontStyle: FontStyle.italic,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
