part of 'repository_provider.dart';

/// Implementation of [StudentRepository] using remote data source.
class StudentRepositoryImpl implements StudentRepository {
  final StudentsRemoteSource _remoteSource;

  StudentRepositoryImpl(this._remoteSource);

  @override
  Future<Student> getStudentById(String studentId) async {
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
    final response = await _remoteSource.updateStudent(studentId, request);
    if (response.data == null) {
      throw Exception('Failed to update student');
    }
    return response.data!.toEntity();
  }

  @override
  Future<List<Student>> getStudentsByClass(String classId) async {
    final response = await _remoteSource.getStudentsByClass(classId);
    if (response.data == null) {
      return [];
    }
    return response.data!.map((dto) => dto.toEntity()).toList();
  }

  @override
  Future<Student> createAndEnrollStudent(
    String classId,
    StudentCreateRequestDto request,
  ) async {
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
    await _remoteSource.removeStudentFromClass(classId, studentId);
  }
}
