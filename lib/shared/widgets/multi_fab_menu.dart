import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// A single action item for [MultiFabMenu].
class FabAction {
  const FabAction({
    required this.heroTag,
    required this.icon,
    required this.label,
    required this.onPressed,
    this.backgroundColor,
    this.foregroundColor,
    this.elevation = 4,
  });

  final String heroTag;
  final IconData icon;
  final String label;
  final VoidCallback onPressed;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double elevation;
}

/// An expandable speed-dial FAB.
///
/// Renders a single round toggle button. When tapped, [actions] animate in
/// above it (staggered, bottom-first). Tapping an action or the toggle again
/// collapses the menu.
///
/// Example:
/// ```dart
/// MultiFabMenu(
///   actions: [
///     FabAction(
///       heroTag: 'fab_generate',
///       icon: Icons.auto_awesome_rounded,
///       label: 'Generate with AI',
///       onPressed: () { ... },
///     ),
///     FabAction(
///       heroTag: 'fab_create',
///       icon: Icons.add_rounded,
///       label: 'Add Question',
///       onPressed: () { ... },
///     ),
///   ],
/// )
/// ```
class MultiFabMenu extends StatefulWidget {
  const MultiFabMenu({
    super.key,
    required this.actions,
    this.mainHeroTag = 'fab_menu_toggle',
    this.spacing = 12,
  }) : assert(actions.length > 0, 'actions must not be empty');

  final List<FabAction> actions;

  /// Hero tag for the main toggle button.
  final String mainHeroTag;

  /// Vertical gap between each action FAB and the one below it.
  final double spacing;

  @override
  State<MultiFabMenu> createState() => _MultiFabMenuState();
}

class _MultiFabMenuState extends State<MultiFabMenu>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final List<Animation<double>> _itemAnimations;
  bool _isOpen = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 280),
      vsync: this,
    );
    _buildItemAnimations();
  }

  void _buildItemAnimations() {
    final n = widget.actions.length;
    // Stagger: bottom item (index n-1) animates first on open,
    // top item (index 0) animates first on close.
    const staggerStep = 0.15;
    _itemAnimations = List.generate(n, (i) {
      final staggeredIndex = n - 1 - i; // 0 = bottom item
      final openStart = staggeredIndex * staggerStep;
      final openEnd = (openStart + 0.75).clamp(0.0, 1.0);
      final closeStart = i * staggerStep;
      final closeEnd = (closeStart + 0.75).clamp(0.0, 1.0);
      return CurvedAnimation(
        parent: _controller,
        curve: Interval(openStart, openEnd, curve: Curves.easeOutCubic),
        reverseCurve: Interval(closeStart, closeEnd, curve: Curves.easeInCubic),
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggle() {
    HapticFeedback.lightImpact();
    setState(() {
      _isOpen = !_isOpen;
      _isOpen ? _controller.forward() : _controller.reverse();
    });
  }

  void _handleAction(VoidCallback callback) {
    _toggle();
    callback();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Align(
          alignment: Alignment.centerRight,
          child: IntrinsicWidth(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                for (int i = 0; i < widget.actions.length; i++)
                  _ActionItem(
                    action: widget.actions[i],
                    animation: _itemAnimations[i],
                    spacing: widget.spacing,
                    onTap: () => _handleAction(widget.actions[i].onPressed),
                  ),
              ],
            ),
          ),
        ),

        FloatingActionButton(
          heroTag: widget.mainHeroTag,
          onPressed: _toggle,
          elevation: 6,
          child: AnimatedBuilder(
            animation: _controller,
            builder: (_, _) => Transform.rotate(
              angle: _controller.value * 0.785398, // 45° in radians
              child: Icon(_isOpen ? Icons.close_rounded : Icons.add_rounded),
            ),
          ),
        ),
      ],
    );
  }
}

class _ActionItem extends StatelessWidget {
  const _ActionItem({
    required this.action,
    required this.animation,
    required this.spacing,
    required this.onTap,
  });

  final FabAction action;
  final Animation<double> animation;
  final double spacing;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizeTransition(
      sizeFactor: animation,
      axisAlignment: 1,
      child: Padding(
        padding: EdgeInsets.only(bottom: spacing),
        child: FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.4),
              end: Offset.zero,
            ).animate(animation),
            child: Align(
              alignment: Alignment.centerRight,
              child: FloatingActionButton.extended(
                heroTag: action.heroTag,
                onPressed: onTap,
                elevation: action.elevation,
                backgroundColor: action.backgroundColor,
                foregroundColor: action.foregroundColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                icon: Icon(action.icon),
                label: Text(action.label),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
