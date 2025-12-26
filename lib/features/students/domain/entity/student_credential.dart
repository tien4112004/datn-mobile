class StudentCredential {
  final String studentId;
  final String username;
  final String password;
  final String email;
  final String fullName;

  StudentCredential({
    required this.studentId,
    required this.username,
    required this.password,
    required this.email,
    required this.fullName,
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
