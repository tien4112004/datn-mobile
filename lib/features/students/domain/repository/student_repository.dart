import 'dart:io';

import 'package:datn_mobile/features/students/data/dto/student_create_request_dto.dart';
import 'package:datn_mobile/features/students/data/dto/student_update_request_dto.dart';
import 'package:datn_mobile/features/students/domain/entity/student.dart';
import 'package:datn_mobile/features/students/domain/entity/student_import_result.dart';

/// Repository interface for student operations.
/// Abstracts data source implementation from domain layer.
abstract class StudentRepository {
  /// Fetches a student by their unique ID.
  Future<Student> getStudentById(String studentId);

  /// Updates an existing student's information.
  Future<Student> updateStudent(
    String studentId,
    StudentUpdateRequestDto request,
  );

  /// Fetches all students enrolled in a specific class.
  Future<List<Student>> getStudentsByClass(
    String classId, {
    int page = 1,
    int size = 10,
  });

  /// Creates a new student and enrolls them in a class.
  Future<Student> createAndEnrollStudent(
    String classId,
    StudentCreateRequestDto request,
  );

  /// Imports students from a file (Excel/CSV).
  Future<StudentImportResult> importStudents(String classId, File file);

  /// Removes a student from a class.
  Future<void> removeStudentFromClass(String classId, String studentId);
}
