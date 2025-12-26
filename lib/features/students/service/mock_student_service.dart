part of 'service_provider.dart';

/// Mock implementation of [StudentService] for testing UI without real data.
class MockStudentService implements StudentService {
  @override
  Future<Student> getStudentById(String studentId) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));

    return Student(
      id: studentId,
      userId: 'user-$studentId',
      enrollmentDate: DateTime.now().subtract(const Duration(days: 30)),
      address: '123 Main St, City',
      parentContactEmail: 'parent@example.com',
      status: StudentStatus.active,
      createdAt: DateTime.now().subtract(const Duration(days: 60)),
      updatedAt: DateTime.now(),
      username: 'student$studentId',
      email: 'student$studentId@example.com',
      firstName: 'John',
      lastName: 'Doe',
      avatarUrl: null,
      phoneNumber: '+1234567890',
    );
  }

  @override
  Future<Student> updateStudent(
    String studentId,
    StudentUpdateRequestDto request,
  ) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));

    // Get the existing student first
    final existing = await getStudentById(studentId);

    return existing.copyWith(
      address: request.address,
      parentContactEmail: request.parentContactEmail,
      enrollmentDate: request.enrollmentDate,
      updatedAt: DateTime.now(),
    );
  }

  @override
  Future<List<Student>> getStudentsByClass(String classId) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 800));

    // Return mock students for the mock class
    if (classId == 'mock-class-1') {
      return [
        Student(
          id: 'student-1',
          userId: 'user-1',
          enrollmentDate: DateTime.now().subtract(const Duration(days: 90)),
          address: '123 Oak Street, Springfield',
          parentContactEmail: 'parent1@example.com',
          status: StudentStatus.active,
          createdAt: DateTime.now().subtract(const Duration(days: 120)),
          updatedAt: DateTime.now().subtract(const Duration(days: 5)),
          username: 'alice_wonder',
          email: 'alice@example.com',
          firstName: 'Alice',
          lastName: 'Wonder',
          avatarUrl: null,
          phoneNumber: '+1234567890',
        ),
        Student(
          id: 'student-2',
          userId: 'user-2',
          enrollmentDate: DateTime.now().subtract(const Duration(days: 60)),
          address: '456 Maple Avenue, Springfield',
          parentContactEmail: 'parent2@example.com',
          status: StudentStatus.active,
          createdAt: DateTime.now().subtract(const Duration(days: 90)),
          updatedAt: DateTime.now().subtract(const Duration(days: 2)),
          username: 'bob_builder',
          email: 'bob@example.com',
          firstName: 'Bob',
          lastName: 'Builder',
          avatarUrl: null,
          phoneNumber: '+1234567891',
        ),
        Student(
          id: 'student-3',
          userId: 'user-3',
          enrollmentDate: DateTime.now().subtract(const Duration(days: 45)),
          address: '789 Pine Road, Springfield',
          parentContactEmail: 'parent3@example.com',
          status: StudentStatus.active,
          createdAt: DateTime.now().subtract(const Duration(days: 75)),
          updatedAt: DateTime.now().subtract(const Duration(days: 1)),
          username: 'charlie_brown',
          email: 'charlie@example.com',
          firstName: 'Charlie',
          lastName: 'Brown',
          avatarUrl: null,
          phoneNumber: '+1234567892',
        ),
        Student(
          id: 'student-4',
          userId: 'user-4',
          enrollmentDate: DateTime.now().subtract(const Duration(days: 30)),
          address: '321 Elm Street, Springfield',
          parentContactEmail: 'parent4@example.com',
          status: StudentStatus.active,
          createdAt: DateTime.now().subtract(const Duration(days: 60)),
          updatedAt: DateTime.now(),
          username: 'diana_prince',
          email: 'diana@example.com',
          firstName: 'Diana',
          lastName: 'Prince',
          avatarUrl: null,
          phoneNumber: '+1234567893',
        ),
        Student(
          id: 'student-5',
          userId: 'user-5',
          enrollmentDate: DateTime.now().subtract(const Duration(days: 15)),
          address: '654 Birch Lane, Springfield',
          parentContactEmail: 'parent5@example.com',
          status: StudentStatus.active,
          createdAt: DateTime.now().subtract(const Duration(days: 45)),
          updatedAt: DateTime.now(),
          username: 'ethan_hunt',
          email: 'ethan@example.com',
          firstName: 'Ethan',
          lastName: 'Hunt',
          avatarUrl: null,
          phoneNumber: '+1234567894',
        ),
      ];
    }

    // Return empty list for other classes
    return [];
  }

  @override
  Future<Student> createAndEnrollStudent(
    String classId,
    StudentCreateRequestDto request,
  ) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 800));

    final newId = 'student-${DateTime.now().millisecondsSinceEpoch}';
    final now = DateTime.now();

    // Parse fullName into firstName and lastName
    final nameParts = request.fullName.trim().split(' ');
    final firstName = nameParts.isNotEmpty ? nameParts.first : '';
    final lastName = nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '';

    return Student(
      id: newId,
      userId: 'user-$newId',
      enrollmentDate: request.enrollmentDate ?? now,
      address: request.address,
      parentContactEmail: request.parentContactEmail,
      status: StudentStatus.active,
      createdAt: now,
      updatedAt: now,
      username: 'student_${newId.substring(newId.length - 6)}',
      email: '${firstName.toLowerCase()}@example.com',
      firstName: firstName,
      lastName: lastName,
      avatarUrl: null,
      phoneNumber: request.parentPhone,
    );
  }

  @override
  Future<void> removeStudentFromClass(String classId, String studentId) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));
    // Mock implementation - just return
    return;
  }
}
