import 'package:flutter/material.dart';

class SamplePrompt extends StatefulWidget {
  final String text;
  final bool selected;
  final VoidCallback onTap;
  final bool visible;

  const SamplePrompt({
    super.key,
    required this.text,
    this.selected = false,
    required this.onTap,
    this.visible = true,
  });

  @override
  State<SamplePrompt> createState() => _SamplePromptState();
}

class _SamplePromptState extends State<SamplePrompt>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.8,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    if (!widget.visible) {
      _controller.value = 1.0;
    }
  }

  @override
  void didUpdateWidget(SamplePrompt oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.visible != widget.visible) {
      if (widget.visible) {
        _controller.reverse();
      } else {
        _controller.forward();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).colorScheme.primary;

    // Theme-aware colors using primary color
    final bg = widget.selected
        ? (isDark
              ? primaryColor.withValues(alpha: 0.2)
              : primaryColor.withValues(alpha: 0.1))
        : (isDark ? Colors.grey[800]! : const Color(0xFFF3F4F6));

    final fg = widget.selected
        ? primaryColor
        : (isDark ? Colors.grey[300]! : Colors.black87);

    final borderColor = widget.selected
        ? (isDark
              ? primaryColor.withValues(alpha: 0.5)
              : primaryColor.withValues(alpha: 0.3))
        : (isDark ? Colors.grey[700]! : const Color(0xFFE6E6E6));

    return FadeTransition(
      opacity: _fadeAnimation,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: GestureDetector(
          onTap: widget.onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: borderColor),
            ),
            child: Text(
              widget.text,
              style: TextStyle(
                color: fg,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
