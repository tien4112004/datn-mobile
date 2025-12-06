enum ContentLength {
  short('short', 'Short'),
  medium('medium', 'Medium'),
  long('long', 'Long');

  final String value;
  final String displayName;

  const ContentLength(this.value, this.displayName);
}
