class ModelInfo {
  final String name;
  final String provider;

  const ModelInfo({required this.name, required this.provider});

  ModelInfo copyWith({String? name, String? provider}) {
    return ModelInfo(
      name: name ?? this.name,
      provider: provider ?? this.provider,
    );
  }

  Map<String, dynamic> toJson() => {'name': name, 'provider': provider};

  factory ModelInfo.fromJson(Map<String, dynamic> json) {
    return ModelInfo(
      name: json['name'] as String,
      provider: json['provider'] as String,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ModelInfo &&
        other.name == name &&
        other.provider == provider;
  }

  @override
  int get hashCode => name.hashCode ^ provider.hashCode;

  static const defaultTextModelName = 'gpt-4o';
  static const defaultTextModelProvider = 'openai';

  static const defaultImageModelName = 'google/gemini-2.5-flash-image-preview';
  static const defaultImageModelProvider = 'openRouter';

  static ModelInfo getDefault() {
    return const ModelInfo(
      name: defaultTextModelName,
      provider: defaultTextModelProvider,
    );
  }

  static ModelInfo getDefaultImageModel() {
    return const ModelInfo(
      name: defaultImageModelName,
      provider: defaultImageModelProvider,
    );
  }
}
