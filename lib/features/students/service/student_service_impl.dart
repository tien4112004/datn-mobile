part of 'service_provider.dart';

/// Implementation of [StudentService] with business logic validation.
class StudentServiceImpl implements StudentService {
  final StudentRepository _repository;

  StudentServiceImpl(this._repository);

  @override
  Future<Student> getStudentById(String studentId) {
    if (studentId.trim().isEmpty) {
      throw ArgumentError('Student ID cannot be empty');
    }
    return _repository.getStudentById(studentId);
  }

  @override
  Future<Student> updateStudent(
    String studentId,
    StudentUpdateRequestDto request,
  ) {
    if (studentId.trim().isEmpty) {
      throw ArgumentError('Student ID cannot be empty');
    }
    return _repository.updateStudent(studentId, request);
  }

  @override
  Future<List<Student>> getStudentsByClass(String classId) {
    if (classId.trim().isEmpty) {
      throw ArgumentError('Class ID cannot be empty');
    }
    return _repository.getStudentsByClass(classId);
  }

  @override
  Future<Student> createAndEnrollStudent(
    String classId,
    StudentCreateRequestDto request,
  ) {
    // Validate required fields
    if (classId.trim().isEmpty) {
      throw ArgumentError('Class ID cannot be empty');
    }
    if (request.fullName.trim().isEmpty) {
      throw ArgumentError('Full name is required');
    }
    if (request.parentName.trim().isEmpty) {
      throw ArgumentError('Parent name is required');
    }
    if (request.parentPhone.trim().isEmpty) {
      throw ArgumentError('Parent phone is required');
    }
    return _repository.createAndEnrollStudent(classId, request);
  }

  @override
  Future<void> removeStudentFromClass(String classId, String studentId) {
    if (classId.trim().isEmpty) {
      throw ArgumentError('Class ID cannot be empty');
    }
    if (studentId.trim().isEmpty) {
      throw ArgumentError('Student ID cannot be empty');
    }
    return _repository.removeStudentFromClass(classId, studentId);
  }
}
