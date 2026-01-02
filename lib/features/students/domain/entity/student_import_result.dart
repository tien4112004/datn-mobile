import 'package:datn_mobile/features/students/domain/entity/student_credential.dart';

class StudentImportResult {
  final bool success;
  final int studentsCreated;
  final String? message;
  final List<StudentCredential> credentials;
  final List<String> errors;

  StudentImportResult({
    required this.success,
    required this.studentsCreated,
    this.message,
    required this.credentials,
    required this.errors,
  });
}
