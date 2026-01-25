enum PermissionLevel {
  view('view'),
  comment('comment');

  final String value;
  const PermissionLevel(this.value);

  static PermissionLevel fromValue(String value) {
    return values.firstWhere(
      (e) => e.value == value,
      orElse: () => PermissionLevel.view,
    );
  }
}
