import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// Countdown timer widget for timed assignments
class TimerWidget extends ConsumerStatefulWidget {
  final DateTime startTime;
  final int durationMinutes;
  final VoidCallback onTimeUp;

  const TimerWidget({
    super.key,
    required this.startTime,
    required this.durationMinutes,
    required this.onTimeUp,
  });

  @override
  ConsumerState<TimerWidget> createState() => _TimerWidgetState();
}

class _TimerWidgetState extends ConsumerState<TimerWidget> {
  Timer? _timer;
  Duration _remainingTime = Duration.zero;

  @override
  void initState() {
    super.initState();
    _calculateRemainingTime();
    _startTimer();
  }

  void _calculateRemainingTime() {
    final endTime = widget.startTime.add(
      Duration(minutes: widget.durationMinutes),
    );
    final now = DateTime.now();
    _remainingTime = endTime.difference(now);

    if (_remainingTime.isNegative) {
      _remainingTime = Duration.zero;
    }
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _calculateRemainingTime();

        if (_remainingTime.inSeconds <= 0) {
          _timer?.cancel();
          widget.onTimeUp();
        }
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String _formatTime(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  Color _getColorForTime(Duration remaining, ColorScheme colorScheme) {
    if (remaining.inMinutes < 5) {
      return Colors.red;
    } else if (remaining.inMinutes < 10) {
      return Colors.orange;
    } else {
      return colorScheme.onSurfaceVariant;
    }
  }

  @override
  Widget build(BuildContext context) {
    // final t = ref.watch(translationsPod);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final color = _getColorForTime(_remainingTime, colorScheme);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(LucideIcons.clock, size: 14, color: color),
        const SizedBox(width: 4),
        Text(
          _formatTime(_remainingTime),
          style: theme.textTheme.bodySmall?.copyWith(
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
