import 'dart:core';

import 'package:datn_mobile/features/projects/enum/slide_element_type.dart';

class SlideElement {
  SlideElementType type;
  String id;
  double left;
  double top;
  double width;
  double height;
  List<double> viewBox;
  String path;
  String fill;
  bool fixedRatio;
  double opacity;
  double rotate;
  bool flipV;
  double lineHeight;
  String content;
  String defaultFontName;
  String defaultColor;
  List<double> start;
  List<double> end;
  List<String> points;
  String color;
  String style;
  double wordSpace;
  Map<String, Object> extraFields = <String, Object>{};

  SlideElement({
    required this.type,
    required this.id,
    required this.left,
    required this.top,
    required this.width,
    required this.height,
    required this.viewBox,
    required this.path,
    required this.fill,
    required this.fixedRatio,
    required this.opacity,
    required this.rotate,
    required this.flipV,
    required this.lineHeight,
    required this.content,
    required this.defaultFontName,
    required this.defaultColor,
    required this.start,
    required this.end,
    required this.points,
    required this.color,
    required this.style,
    required this.wordSpace,
  });

  void setExtraField(String key, Object value) {
    extraFields[key] = value;
  }

  Map<String, Object> getExtraFields() {
    return extraFields;
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type.value,
      'id': id,
      'left': left,
      'top': top,
      'width': width,
      'height': height,
      if (viewBox.isNotEmpty) 'viewBox': viewBox,
      if (path.isNotEmpty) 'path': path,
      if (fill.isNotEmpty) 'fill': fill,
      'fixedRatio': fixedRatio,
      'opacity': opacity,
      'rotate': rotate,
      'flipV': flipV,
      if (lineHeight != 0) 'lineHeight': lineHeight,
      if (content.isNotEmpty) 'content': content,
      if (defaultFontName.isNotEmpty) 'defaultFontName': defaultFontName,
      if (defaultColor.isNotEmpty) 'defaultColor': defaultColor,
      if (start.isNotEmpty) 'start': start,
      if (end.isNotEmpty) 'end': end,
      if (points.isNotEmpty) 'points': points,
      if (color.isNotEmpty) 'color': color,
      if (style.isNotEmpty) 'style': style,
      if (wordSpace != 0) 'wordSpace': wordSpace,
      ...extraFields,
    };
  }
}
