/// Enum representing the theme for presentation.
enum PresentationTheme {
  modern('modern', 'Modern'),
  classic('classic', 'Classic'),
  minimal('minimal', 'Minimal'),
  vibrant('vibrant', 'Vibrant');

  final String value;
  final String displayName;

  const PresentationTheme(this.value, this.displayName);

  static List<String> get displayNames =>
      values.map((e) => e.displayName).toList();

  static PresentationTheme fromDisplayName(String name) {
    return values.firstWhere(
      (e) => e.displayName.toLowerCase() == name.toLowerCase(),
      orElse: () => PresentationTheme.modern,
    );
  }

  static PresentationTheme fromValue(String value) {
    return values.firstWhere(
      (e) => e.value == value,
      orElse: () => PresentationTheme.modern,
    );
  }
}
