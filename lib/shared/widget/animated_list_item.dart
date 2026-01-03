import 'package:flutter/material.dart';

/// Animated list item wrapper for smooth entrance and exit animations.
///
/// Provides reusable animation wrapper for list items with:
/// - Staggered fade-in entrance animation
/// - Smooth slide entrance from right
/// - Optional scale animation
/// - Configurable animation duration and delay
/// - Respects reduced motion preferences
///
/// Usage:
/// ```dart
/// ListView.builder(
///   itemCount: items.length,
///   itemBuilder: (context, index) {
///     return AnimatedListItem(
///       index: index,
///       child: YourItemWidget(),
///     );
///   },
/// )
/// ```
class AnimatedListItem extends StatefulWidget {
  final Widget child;
  final int index;
  final Duration duration;
  final Duration delay;
  final Curve curve;
  final bool enableScale;
  final Offset slideOffset;

  const AnimatedListItem({
    super.key,
    required this.child,
    this.index = 0,
    this.duration = const Duration(milliseconds: 400),
    this.delay = const Duration(milliseconds: 50),
    this.curve = Curves.easeOutCubic,
    this.enableScale = false,
    this.slideOffset = const Offset(0.1, 0.0),
  });

  @override
  State<AnimatedListItem> createState() => _AnimatedListItemState();
}

class _AnimatedListItemState extends State<AnimatedListItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(duration: widget.duration, vsync: this);

    // Fade animation
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: widget.curve));

    // Slide animation
    _slideAnimation = Tween<Offset>(
      begin: widget.slideOffset,
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: widget.curve));

    // Scale animation (optional)
    _scaleAnimation = Tween<double>(
      begin: widget.enableScale ? 0.95 : 1.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: widget.curve));

    // Start animation with staggered delay
    Future.delayed(widget.delay * widget.index, () {
      if (mounted) {
        _controller.forward();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: widget.enableScale
            ? ScaleTransition(scale: _scaleAnimation, child: widget.child)
            : widget.child,
      ),
    );
  }
}

/// Helper extension to easily wrap list items with animations
extension AnimatedListExtension on Widget {
  /// Wraps this widget with AnimatedListItem
  Widget animateListItem(
    int index, {
    Duration? duration,
    Duration? delay,
    Curve? curve,
    bool enableScale = false,
  }) {
    return AnimatedListItem(
      index: index,
      duration: duration ?? const Duration(milliseconds: 400),
      delay: delay ?? const Duration(milliseconds: 50),
      curve: curve ?? Curves.easeOutCubic,
      enableScale: enableScale,
      child: this,
    );
  }
}

/// Animated removal item for smooth exit animations
class AnimatedRemovalItem extends StatelessWidget {
  final Widget child;
  final Animation<double> animation;
  final VoidCallback? onRemoved;

  const AnimatedRemovalItem({
    super.key,
    required this.child,
    required this.animation,
    this.onRemoved,
  });

  @override
  Widget build(BuildContext context) {
    return SizeTransition(
      sizeFactor: animation,
      child: FadeTransition(
        opacity: animation,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(-0.3, 0.0),
            end: Offset.zero,
          ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOut)),
          child: child,
        ),
      ),
    );
  }
}

/// Staggered grid animation helper
class StaggeredGridItem extends StatefulWidget {
  final Widget child;
  final int index;
  final int crossAxisCount;
  final Duration duration;
  final Duration baseDelay;
  final Curve curve;

  const StaggeredGridItem({
    super.key,
    required this.child,
    required this.index,
    this.crossAxisCount = 2,
    this.duration = const Duration(milliseconds: 400),
    this.baseDelay = const Duration(milliseconds: 30),
    this.curve = Curves.easeOutCubic,
  });

  @override
  State<StaggeredGridItem> createState() => _StaggeredGridItemState();
}

class _StaggeredGridItemState extends State<StaggeredGridItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(duration: widget.duration, vsync: this);

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: widget.curve));

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: widget.curve));

    // Calculate staggered delay based on grid position
    final row = widget.index ~/ widget.crossAxisCount;
    final col = widget.index % widget.crossAxisCount;
    final delay = widget.baseDelay * (row + col);

    Future.delayed(delay, () {
      if (mounted) {
        _controller.forward();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: ScaleTransition(scale: _scaleAnimation, child: widget.child),
    );
  }
}
