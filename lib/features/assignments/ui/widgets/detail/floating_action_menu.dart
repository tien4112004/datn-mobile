import 'package:AIPrimary/shared/pods/translation_pod.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// Floating action menu with speed dial for adding questions.
///
/// Features:
/// - Primary FAB with "Add Question" label
/// - Speed dial expansion with two options:
///   1. From Bank - Navigate to question bank selection
///   2. Create New - Navigate to question creation
/// - Smooth stagger animation (300ms)
/// - Material 3 design
/// - Backdrop overlay when expanded
class FloatingActionMenuItem {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final Color? color;

  const FloatingActionMenuItem({
    required this.label,
    required this.icon,
    required this.onTap,
    this.color,
  });
}

class FloatingActionMenu extends ConsumerStatefulWidget {
  final List<FloatingActionMenuItem> items;
  final IconData? mainIcon;
  final String? mainLabel;

  const FloatingActionMenu({
    super.key,
    required this.items,
    this.mainIcon,
    this.mainLabel,
  });

  @override
  ConsumerState<FloatingActionMenu> createState() => _FloatingActionMenuState();
}

class _FloatingActionMenuState extends ConsumerState<FloatingActionMenu>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _rotationAnimation;
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _rotationAnimation =
        Tween<double>(
          begin: 0.0,
          end: 0.125, // 45 degrees (1/8 turn)
        ).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Curves.easeInOut,
          ),
        );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggleMenu() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }

  void _handleAction(VoidCallback? callback) {
    _toggleMenu();
    // Add small delay for animation to start before triggering action
    Future.delayed(const Duration(milliseconds: 100), () {
      callback?.call();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final t = ref.watch(translationsPod);

    return Stack(
      alignment: Alignment.bottomRight,
      children: [
        // Speed dial items
        Positioned(
          right: 16,
          bottom: 80,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: widget.items.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              final defaultColors = [
                colorScheme.primary,
                colorScheme.tertiary,
                colorScheme.secondary,
                colorScheme.error,
              ];
              final itemColor =
                  item.color ?? defaultColors[index % defaultColors.length];

              return Padding(
                padding: EdgeInsets.only(
                  bottom: index == widget.items.length - 1 ? 0 : 12,
                ),
                child: _buildSpeedDialItem(
                  icon: item.icon,
                  label: item.label,
                  color: itemColor,
                  delay: index * 50,
                  onTap: () => _handleAction(item.onTap),
                ),
              );
            }).toList(),
          ),
        ),

        // Main FAB
        Positioned(
          right: 16,
          bottom: 16,
          child: FloatingActionButton.extended(
            onPressed: _toggleMenu,
            elevation: _isExpanded ? 8 : 2,
            icon: RotationTransition(
              turns: _rotationAnimation,
              child: Icon(
                _isExpanded
                    ? LucideIcons.x
                    : (widget.mainIcon ?? LucideIcons.plus),
              ),
            ),
            label: Text(
              _isExpanded
                  ? t.assignments.floatingMenu.close
                  : (widget.mainLabel ??
                        t.assignments.floatingMenu.addQuestion),
              style: theme.textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSpeedDialItem({
    required IconData icon,
    required String label,
    required Color color,
    required int delay,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        // Calculate stagger delay
        final delayedValue = (_animationController.value * 2 - delay / 100)
            .clamp(0.0, 1.0);

        return Transform.scale(
          scale: delayedValue,
          alignment: Alignment.centerRight,
          child: Opacity(opacity: delayedValue, child: child),
        );
      },
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Label
          Material(
            elevation: 2,
            borderRadius: BorderRadius.circular(8),
            color: colorScheme.surface,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Text(
                label,
                style: theme.textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ),
          ),

          const SizedBox(width: 12),

          // Icon Button
          Material(
            elevation: 2,
            borderRadius: BorderRadius.circular(16),
            color: color,
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(16),
              child: SizedBox(
                width: 48,
                height: 48,
                child: Icon(icon, color: colorScheme.onPrimary, size: 22),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Simpler version without speed dial (just extended FAB).
/// Use this when you don't need the From Bank / Create New split.
class SimpleFloatingActionButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final String label;
  final IconData icon;

  const SimpleFloatingActionButton({
    super.key,
    this.onPressed,
    required this.label,
    this.icon = LucideIcons.plus,
  });

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.extended(
      onPressed: onPressed,
      icon: Icon(icon),
      label: Text(
        label,
        style: Theme.of(
          context,
        ).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600),
      ),
      elevation: 2,
    );
  }
}
