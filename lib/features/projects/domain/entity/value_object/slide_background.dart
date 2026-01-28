class SlideBackground {
  String type;
  String color;
  Map<String, Object> extraFields = <String, Object>{};

  SlideBackground({required this.type, required this.color});

  void setExtraField(String key, Object value) {
    extraFields[key] = value;
  }

  Map<String, Object> getExtraFields() {
    return extraFields;
  }

  Map<String, dynamic> toJson() {
    return {'type': type, 'color': color, ...extraFields};
  }
}
