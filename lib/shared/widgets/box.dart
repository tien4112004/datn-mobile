import 'package:flutter/material.dart';

enum BoxBorderStyle { solid, dashed, none }

class Box extends StatelessWidget {
  final Widget child;
  final BoxBorderStyle borderStyle;
  final EdgeInsets padding;
  final double borderRadius;

  const Box({
    super.key,
    required this.child,
    this.borderStyle = BoxBorderStyle.solid,
    this.padding = const EdgeInsets.all(14),
    this.borderRadius = 14,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    Widget content = Container(
      padding: padding,
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[850] : Colors.white,
        borderRadius: BorderRadius.circular(borderRadius),
        border: borderStyle == BoxBorderStyle.solid
            ? Border.all(
                color: isDark ? Colors.grey[700]! : const Color(0xFFE6E6E6),
              )
            : null,
      ),
      child: child,
    );

    // Wrap with dashed border if needed
    if (borderStyle == BoxBorderStyle.dashed) {
      content = CustomPaint(
        painter: _DashedBorderPainter(
          radius: borderRadius,
          color: isDark ? Colors.grey[600]! : const Color(0xFFD6D6D6),
        ),
        child: content,
      );
    }

    return content;
  }
}

class _DashedBorderPainter extends CustomPainter {
  final double radius;
  final Color color;

  _DashedBorderPainter({required this.radius, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final rrect = RRect.fromRectAndRadius(
      Offset.zero & size,
      Radius.circular(radius),
    );
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..color = color;

    const dash = 6.0;
    const gap = 4.0;

    final path = Path()..addRRect(rrect);
    for (final metric in path.computeMetrics()) {
      double dist = 0.0;
      while (dist < metric.length) {
        double end = (dist + dash).clamp(0, metric.length).toDouble();
        final extract = metric.extractPath(dist, end);
        canvas.drawPath(extract, paint);
        dist += dash + gap;
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
