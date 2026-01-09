class StudentCredential {
  final String studentId;
  final String username;
  final String password;
  final String email;
  final String fullName;
  final List<String> errors;

  StudentCredential({
    required this.studentId,
    required this.username,
    required this.password,
    required this.email,
    required this.fullName,
    this.errors = const [],
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StudentCredential &&
          runtimeType == other.runtimeType &&
          studentId == other.studentId;

  @override
  int get hashCode => studentId.hashCode;
}
