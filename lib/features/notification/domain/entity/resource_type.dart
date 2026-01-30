enum ResourceType {
  presentation,
  mindmap,
  image;

  static ResourceType? fromString(String? value) {
    if (value == null) return null;
    return ResourceType.values.cast<ResourceType?>().firstWhere(
      (e) => e?.name.toLowerCase() == value.toLowerCase(),
      orElse: () => null,
    );
  }
}
