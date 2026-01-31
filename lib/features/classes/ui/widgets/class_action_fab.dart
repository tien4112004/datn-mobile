import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:AIPrimary/shared/pods/translation_pod.dart';

/// Expandable Floating Action Button for class actions.
///
/// Shows options to Create Class or Join Class when tapped.
class ClassActionFab extends ConsumerStatefulWidget {
  final VoidCallback onCreateClass;
  final VoidCallback? onJoinClass;

  const ClassActionFab({
    super.key,
    required this.onCreateClass,
    this.onJoinClass,
  });

  @override
  ConsumerState<ClassActionFab> createState() => _ClassActionFabState();
}

class _ClassActionFabState extends ConsumerState<ClassActionFab>
    with SingleTickerProviderStateMixin {
  bool _isExpanded = false;
  late AnimationController _animationController;
  late Animation<double> _expandAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _expandAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggle() {
    HapticFeedback.lightImpact();
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }

  void _handleAction(VoidCallback action) {
    _toggle();
    action();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final t = ref.watch(translationsPod);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // Expanded options
        SizeTransition(
          axis: Axis.horizontal,
          axisAlignment: 1.0,
          sizeFactor: _expandAnimation,
          child: Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // Join Class option
                if (widget.onJoinClass != null) ...[
                  _buildMiniAction(
                    context,
                    label: t.classes.joinClass,
                    icon: LucideIcons.userPlus,
                    onTap: () => _handleAction(widget.onJoinClass!),
                  ),
                  const SizedBox(height: 8),
                ],
                // Create Class option
                _buildMiniAction(
                  context,
                  label: t.classes.createClass,
                  icon: LucideIcons.plus,
                  onTap: () => _handleAction(widget.onCreateClass),
                ),
              ],
            ),
          ),
        ),
        // Main FAB
        FloatingActionButton(
          onPressed: _toggle,
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          child: AnimatedRotation(
            turns: _isExpanded ? 0.125 : 0,
            duration: const Duration(milliseconds: 200),
            child: const Icon(LucideIcons.plus),
          ),
        ),
      ],
    );
  }

  Widget _buildMiniAction(
    BuildContext context, {
    required String label,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return Semantics(
      label: label,
      button: true,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Label chip
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: colorScheme.onSurface,
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Mini FAB
          FloatingActionButton.small(
            heroTag: label,
            onPressed: onTap,
            backgroundColor: colorScheme.primaryContainer,
            foregroundColor: colorScheme.onPrimaryContainer,
            elevation: 2,
            child: Icon(icon, size: 20),
          ),
        ],
      ),
    );
  }
}
