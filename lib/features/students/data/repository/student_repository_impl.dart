part of 'repository_provider.dart';

/// Implementation of [StudentRepository] using remote data source.
class StudentRepositoryImpl implements StudentRepository {
  final StudentsRemoteSource _remoteSource;

  StudentRepositoryImpl(this._remoteSource);

  @override
  Future<Student> getStudentById(String studentId) async {
    if (studentId.trim().isEmpty) {
      throw ArgumentError('Student ID cannot be empty');
    }
    final response = await _remoteSource.getStudentById(studentId);
    if (response.data == null) {
      throw Exception('Student not found');
    }
    return response.data!.toEntity();
  }

  @override
  Future<Student> updateStudent(
    String studentId,
    StudentUpdateRequestDto request,
  ) async {
    if (studentId.trim().isEmpty) {
      throw ArgumentError('Student ID cannot be empty');
    }
    final response = await _remoteSource.updateStudent(studentId, request);
    if (response.data == null) {
      throw Exception('Failed to update student');
    }
    return response.data!.toEntity();
  }

  @override
  Future<List<Student>> getStudentsByClass(String classId) async {
    if (classId.trim().isEmpty) {
      throw ArgumentError('Class ID cannot be empty');
    }
    const pageSize = 100;
    final firstResponse = await _remoteSource.getStudentsByClass(
      classId,
      1,
      pageSize,
    );
    final firstPage = firstResponse.data ?? [];
    final totalPages = firstResponse.pagination?.totalPages ?? 1;

    if (totalPages <= 1) {
      return firstPage.map((dto) => dto.toEntity()).toList();
    }

    final remaining = await Future.wait([
      for (int p = 2; p <= totalPages; p++)
        _remoteSource.getStudentsByClass(classId, p, pageSize),
    ]);

    final allStudents = firstPage.map((dto) => dto.toEntity()).toList();
    for (final r in remaining) {
      allStudents.addAll((r.data ?? []).map((dto) => dto.toEntity()));
    }
    return allStudents;
  }

  @override
  Future<StudentImportResult> importStudents(String classId, File file) async {
    if (classId.trim().isEmpty) {
      throw ArgumentError('Class ID cannot be empty');
    }
    final response = await _remoteSource.importStudents(classId, file);
    if (response.data == null) {
      throw Exception('Failed to import students');
    }
    return response.data!.toEntity();
  }

  @override
  Future<Student> createAndEnrollStudent(
    String classId,
    StudentCreateRequestDto request,
  ) async {
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

    final response = await _remoteSource.createAndEnrollStudent(
      classId,
      request,
    );
    if (response.data == null) {
      throw Exception('Failed to create student');
    }
    return response.data!.toEntity();
  }

  @override
  Future<void> removeStudentFromClass(String classId, String studentId) async {
    if (classId.trim().isEmpty) {
      throw ArgumentError('Class ID cannot be empty');
    }
    if (studentId.trim().isEmpty) {
      throw ArgumentError('Student ID cannot be empty');
    }
    await _remoteSource.removeStudentFromClass(classId, studentId);
  }
}
