/// Enum representing AI model types
enum ModelType {
  text('TEXT'),
  image('IMAGE');

  final String value;
  const ModelType(this.value);

  /// Convert from API string value to enum
  static ModelType fromValue(String value) {
    return ModelType.values.firstWhere(
      (e) => e.value == value,
      orElse: () => ModelType.text,
    );
  }
}

/// Domain entity representing an AI model from the backend
class AIModel {
  final int id;
  final String name; // e.g., "gpt-4", "claude-3", "dall-e-3"
  final String displayName; // e.g., "GPT-4", "Claude 3"
  final ModelType type; // TEXT or IMAGE
  final bool isDefault;
  final bool isEnabled;

  const AIModel({
    required this.id,
    required this.name,
    required this.displayName,
    required this.type,
    required this.isDefault,
    required this.isEnabled,
  });

  AIModel copyWith({
    int? id,
    String? name,
    String? displayName,
    ModelType? type,
    bool? isDefault,
    bool? isEnabled,
  }) {
    return AIModel(
      id: id ?? this.id,
      name: name ?? this.name,
      displayName: displayName ?? this.displayName,
      type: type ?? this.type,
      isDefault: isDefault ?? this.isDefault,
      isEnabled: isEnabled ?? this.isEnabled,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AIModel &&
        other.id == id &&
        other.name == name &&
        other.type == type;
  }

  @override
  int get hashCode => Object.hash(id, name, type);
}
