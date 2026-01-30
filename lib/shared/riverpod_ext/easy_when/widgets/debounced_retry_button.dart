import 'dart:async';

import 'package:AIPrimary/shared/riverpod_ext/easy_when/easy_when_config.dart';
import 'package:flutter/material.dart';

class DebouncedRetryButton extends StatefulWidget {
  final VoidCallback onPressed;
  final RetryConfig config;
  final String defaultLabel;

  const DebouncedRetryButton({
    required this.onPressed,
    required this.config,
    required this.defaultLabel,
    super.key,
  });

  @override
  State<DebouncedRetryButton> createState() => _DebouncedRetryButtonState();
}

class _DebouncedRetryButtonState extends State<DebouncedRetryButton> {
  late Timer _debounceTimer;
  bool _isDebouncing = false;

  @override
  void initState() {
    super.initState();
    _debounceTimer = Timer.periodic(Duration.zero, (_) {});
    _debounceTimer.cancel();
  }

  @override
  void dispose() {
    _debounceTimer.cancel();
    super.dispose();
  }

  void _handlePress() {
    if (_isDebouncing) return;

    // Execute the callback immediately
    widget.onPressed();

    // Set debouncing state
    if (widget.config.debounceDuration > Duration.zero) {
      setState(() => _isDebouncing = true);

      _debounceTimer = Timer(widget.config.debounceDuration, () {
        if (mounted) {
          setState(() => _isDebouncing = false);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // If custom button builder is provided, use it
    if (widget.config.buttonBuilder != null) {
      return widget.config.buttonBuilder!(
        _isDebouncing ? () => {} : _handlePress,
      );
    }

    // Default button style
    final cs = Theme.of(context).colorScheme;
    final buttonStyle =
        widget.config.buttonStyle ??
        ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          backgroundColor: _isDebouncing
              ? cs.primary.withValues(alpha: 0.5)
              : cs.primary,
        );

    return ElevatedButton(
      onPressed: _isDebouncing ? null : _handlePress,
      style: buttonStyle,
      child: Text(widget.config.buttonLabel ?? widget.defaultLabel),
    );
  }
}
