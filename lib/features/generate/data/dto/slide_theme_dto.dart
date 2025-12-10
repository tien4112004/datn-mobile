import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';

part 'slide_theme_dto.g.dart';

/// Represents a color with position in a gradient
@JsonSerializable()
class GradientColorDto {
  final String color;
  final double pos; // 0-100

  const GradientColorDto({required this.color, required this.pos});

  factory GradientColorDto.fromJson(Map<String, dynamic> json) =>
      _$GradientColorDtoFromJson(json);

  Map<String, dynamic> toJson() => _$GradientColorDtoToJson(this);
}

/// Represents a gradient background
@JsonSerializable()
class GradientDto {
  final String type; // 'linear' or 'radial'
  final List<GradientColorDto> colors;
  final double rotate; // degrees, for linear gradients

  const GradientDto({
    required this.type,
    required this.colors,
    this.rotate = 0,
  });

  factory GradientDto.fromJson(Map<String, dynamic> json) =>
      _$GradientDtoFromJson(json);

  Map<String, dynamic> toJson() => _$GradientDtoToJson(this);
}

/// Outline style for elements
@JsonSerializable()
class OutlineDto {
  final String style; // 'solid', 'dashed', 'dotted'
  final double width;
  final String color;

  const OutlineDto({
    required this.style,
    required this.width,
    required this.color,
  });

  factory OutlineDto.fromJson(Map<String, dynamic> json) =>
      _$OutlineDtoFromJson(json);

  Map<String, dynamic> toJson() => _$OutlineDtoToJson(this);
}

/// Shadow effect for elements
@JsonSerializable()
class ShadowDto {
  final double h; // horizontal offset
  final double v; // vertical offset
  final double blur;
  final String color;

  const ShadowDto({
    required this.h,
    required this.v,
    required this.blur,
    required this.color,
  });

  factory ShadowDto.fromJson(Map<String, dynamic> json) =>
      _$ShadowDtoFromJson(json);

  Map<String, dynamic> toJson() => _$ShadowDtoToJson(this);
}

/// Card styling configuration
@JsonSerializable()
class CardConfigDto {
  final bool enabled;
  final double borderRadius;
  final double borderWidth;
  final String fill; // 'none', 'full', 'semi'
  final ShadowDto shadow;
  final String backgroundColor;
  final String textColor;

  const CardConfigDto({
    required this.enabled,
    required this.borderRadius,
    required this.borderWidth,
    required this.fill,
    required this.shadow,
    required this.backgroundColor,
    required this.textColor,
  });

  factory CardConfigDto.fromJson(Map<String, dynamic> json) =>
      _$CardConfigDtoFromJson(json);

  Map<String, dynamic> toJson() => _$CardConfigDtoToJson(this);
}

/// DTO for SlideTheme from API
@JsonSerializable()
class SlideThemeDto {
  final String id;
  final String name;

  @JsonKey(name: 'backgroundColor')
  final dynamic backgroundColor; // Can be string or gradient object

  @JsonKey(name: 'themeColors')
  final List<String> themeColors;

  @JsonKey(name: 'fontColor')
  final String fontColor;

  @JsonKey(name: 'fontName')
  final String fontName;

  @JsonKey(name: 'titleFontName')
  final String? titleFontName;

  @JsonKey(name: 'titleFontColor')
  final String? titleFontColor;

  @JsonKey(name: 'labelFontColor')
  final String? labelFontColor;

  @JsonKey(name: 'labelFontName')
  final String? labelFontName;

  final OutlineDto? outline;
  final ShadowDto? shadow;

  @JsonKey(name: 'accentImageShape')
  final String? accentImageShape;

  final CardConfigDto? card;

  @JsonKey(name: 'additionalElements')
  final List<dynamic>? additionalElements;

  const SlideThemeDto({
    required this.id,
    required this.name,
    required this.backgroundColor,
    required this.themeColors,
    required this.fontColor,
    required this.fontName,
    this.titleFontName,
    this.titleFontColor,
    this.labelFontColor,
    this.labelFontName,
    this.outline,
    this.shadow,
    this.accentImageShape,
    this.card,
    this.additionalElements,
  });

  factory SlideThemeDto.fromJson(Map<String, dynamic> json) =>
      _$SlideThemeDtoFromJson(json);

  Map<String, dynamic> toJson() => _$SlideThemeDtoToJson(this);

  /// Convert DTO to Flutter Color or Gradient
  dynamic getBackgroundColorOrGradient() {
    if (backgroundColor is String) {
      return parseColor(backgroundColor as String);
    }

    // Try to parse as gradient
    if (backgroundColor is Map<String, dynamic>) {
      final gradientMap = backgroundColor as Map<String, dynamic>;
      try {
        final gradient = GradientDto.fromJson(gradientMap);
        return _buildGradient(gradient);
      } catch (e) {
        // Fallback if gradient parsing fails
        return parseColor(themeColors.isNotEmpty ? themeColors[0] : '#1F2937');
      }
    }

    // Fallback to first theme color
    return parseColor(themeColors.isNotEmpty ? themeColors[0] : '#1F2937');
  }

  /// Build Flutter Gradient from GradientDto
  Gradient _buildGradient(GradientDto gradient) {
    final colors = gradient.colors.map((gc) => parseColor(gc.color)).toList();

    if (gradient.type == 'linear') {
      // Create stops based on positions
      final stops = gradient.colors.map((gc) => gc.pos / 100.0).toList();

      // Use rotation to determine the direction
      final angle = gradient.rotate * math.pi / 180; // Convert to radians
      final begin = Alignment(-1 * math.cos(angle), -1 * math.sin(angle));
      final end = Alignment(math.cos(angle), math.sin(angle));

      return LinearGradient(
        begin: begin,
        end: end,
        colors: colors,
        stops: stops,
      );
    } else if (gradient.type == 'radial') {
      return RadialGradient(
        colors: colors,
        stops: gradient.colors.map((gc) => gc.pos / 100.0).toList(),
      );
    }

    // Fallback to simple linear gradient
    return LinearGradient(colors: colors);
  }

  /// Convert DTO to Flutter Color
  Color getBackgroundColor() {
    final bg = getBackgroundColorOrGradient();
    if (bg is Color) {
      return bg;
    }
    // Fallback color if gradient is returned
    return parseColor(themeColors.isNotEmpty ? themeColors[0] : '#1F2937');
  }

  /// Get theme colors as Flutter Color objects
  List<Color> getThemeColorsAsFlutterColors() {
    return themeColors.map((colorStr) => parseColor(colorStr)).toList();
  }

  /// Parse hex color string to Flutter Color (static public method)
  static Color parseColor(String colorString) {
    String hex = colorString.replaceAll('#', '');
    if (hex.length == 6) {
      hex = 'FF$hex'; // Prepend FF for full opacity (AARRGGBB format)
    } else if (hex.length == 8) {
      // Reorder from RRGGBBAA to AARRGGBB if needed
      // If it's already in AARRGGBB format, keep it as is
      // Assume API sends RRGGBBAA and convert to AARRGGBB
      final aa = hex.substring(6, 8); // Last 2 chars are alpha
      final rrggbb = hex.substring(0, 6); // First 6 chars are RGB
      hex = '$aa$rrggbb';
    }
    return Color(int.parse('0x$hex'));
  }
}
