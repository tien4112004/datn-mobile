import 'package:flutter/material.dart';

enum LoadingStyle { circular, linear, overlay }

enum ErrorStyle { card, inline, minimal }

enum LayoutMode { column, row }

class LoadingConfig {
  final LoadingStyle style;
  final String? message;
  final Color? color;
  final double? size;
  final EdgeInsets padding;

  const LoadingConfig({
    this.style = LoadingStyle.circular,
    this.message,
    this.color,
    this.size,
    this.padding = const EdgeInsets.all(16.0),
  });

  const LoadingConfig.circular({String? message, Color? color, double? size})
    : this(
        style: LoadingStyle.circular,
        message: message,
        color: color,
        size: size,
      );

  const LoadingConfig.linear({String? message, Color? color})
    : this(style: LoadingStyle.linear, message: message, color: color);

  const LoadingConfig.overlay() : this(style: LoadingStyle.overlay);
}

class ErrorConfig {
  final ErrorStyle style;
  final bool showDioErrorDetails;
  final bool showStackTrace;
  final Color? iconColor;
  final Color? textColor;
  final EdgeInsets padding;

  const ErrorConfig({
    this.style = ErrorStyle.card,
    this.showDioErrorDetails = true,
    this.showStackTrace = false,
    this.iconColor,
    this.textColor,
    this.padding = const EdgeInsets.all(16.0),
  });

  const ErrorConfig.minimal({bool showDioErrorDetails = false})
    : this(style: ErrorStyle.minimal, showDioErrorDetails: showDioErrorDetails);

  const ErrorConfig.detailed({bool showStackTrace = false})
    : this(
        style: ErrorStyle.card,
        showStackTrace: showStackTrace,
        showDioErrorDetails: true,
      );

  const ErrorConfig.inline() : this(style: ErrorStyle.inline);
}

class RetryConfig {
  final Duration debounceDuration;
  final Widget Function(void Function() onPressed)? buttonBuilder;
  final ButtonStyle? buttonStyle;
  final String? buttonLabel;

  const RetryConfig({
    this.debounceDuration = const Duration(milliseconds: 500),
    this.buttonBuilder,
    this.buttonStyle,
    this.buttonLabel,
  });

  const RetryConfig.noDebounce({
    Widget Function(VoidCallback onPressed)? buttonBuilder,
    ButtonStyle? buttonStyle,
    String? buttonLabel,
  }) : this(
         debounceDuration: Duration.zero,
         buttonBuilder: buttonBuilder,
         buttonStyle: buttonStyle,
         buttonLabel: buttonLabel,
       );
}
