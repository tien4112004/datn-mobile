import 'package:flutter/material.dart';
import 'package:datn_mobile/shared/widget/box.dart';
import 'package:datn_mobile/shared/widget/info_dot.dart';

class OptionBox extends StatefulWidget {
  final String title;
  final Widget collapsedOptions;
  final Widget? expandedOptions;
  final bool showInfoDot;
  final VoidCallback? onInfoTap;
  final bool initiallyExpanded;

  const OptionBox({
    super.key,
    required this.title,
    required this.collapsedOptions,
    this.expandedOptions,
    this.showInfoDot = true,
    this.onInfoTap,
    this.initiallyExpanded = false,
  });

  @override
  State<OptionBox> createState() => _OptionBoxState();
}

class _OptionBoxState extends State<OptionBox>
    with SingleTickerProviderStateMixin {
  late bool isExpanded;
  late AnimationController _controller;
  late Animation<double> _expandAnimation;

  @override
  void initState() {
    super.initState();
    isExpanded = widget.initiallyExpanded;
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _expandAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );

    if (isExpanded) {
      _controller.value = 1.0;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggleExpanded() {
    setState(() {
      isExpanded = !isExpanded;
      if (isExpanded) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Box(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Text(
                widget.title,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
              if (widget.showInfoDot) ...[
                const SizedBox(width: 6),
                InfoDot(onTap: widget.onInfoTap ?? () {}),
              ],
              const Spacer(),
              GestureDetector(
                onTap: widget.expandedOptions != null ? _toggleExpanded : null,
                child: widget.expandedOptions != null
                    ? Text(
                        isExpanded ? 'Hide advanced' : 'Show advanced',
                        style: TextStyle(
                          color: cs.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      )
                    : const SizedBox.shrink(),
              ),
            ],
          ),
          const SizedBox(height: 12),
          widget.collapsedOptions,
          const SizedBox(height: 24),
          if (widget.expandedOptions != null)
            SizeTransition(
              sizeFactor: _expandAnimation,
              axisAlignment: -1.0,
              child: widget.expandedOptions!,
            ),
        ],
      ),
    );
  }
}
