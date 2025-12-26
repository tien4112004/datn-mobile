part of 'controller_provider.dart';

/// Controller for managing the list of students in a class.
class StudentsController extends AsyncNotifier<StudentListState> {
  StudentsController({required this.classId});

  final String classId;

  @override
  Future<StudentListState> build() async {
    final students = await ref
        .read(studentServiceProvider)
        .getStudentsByClass(classId);
    return StudentListState(value: students, isFetched: true, isLoading: false);
  }

  /// Refreshes the student list.
  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final students = await ref
          .read(studentServiceProvider)
          .getStudentsByClass(classId);
      return StudentListState(
        value: students,
        isFetched: true,
        isLoading: false,
      );
    });
  }
}

/// Controller for creating a new student.
class CreateStudentController extends AsyncNotifier<void> {
  @override
  Future<void> build() async {
    // No-op
  }

  /// Creates a new student and enrolls them in the specified class.
  Future<void> create({
    required String classId,
    required StudentCreateRequestDto request,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref
          .read(studentServiceProvider)
          .createAndEnrollStudent(classId, request);
      // Invalidate the list to trigger a refresh
      ref.invalidate(studentsControllerProvider(classId));
    });
  }
}

/// Controller for updating a student.
class UpdateStudentController extends AsyncNotifier<void> {
  @override
  Future<void> build() async {
    // No-op
  }

  /// Updates an existing student.
  Future<void> updateStudent({
    required String studentId,
    required String classId,
    required StudentUpdateRequestDto request,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(studentServiceProvider).updateStudent(studentId, request);
      // Invalidate the list to trigger a refresh
      ref.invalidate(studentsControllerProvider(classId));
      // Also invalidate the specific student
      ref.invalidate(studentByIdProvider(studentId));
    });
  }
}

/// Controller for removing a student from a class.
class RemoveStudentController extends AsyncNotifier<void> {
  @override
  Future<void> build() async {
    // No-op
  }

  /// Removes a student from the specified class.
  Future<void> remove({
    required String classId,
    required String studentId,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref
          .read(studentServiceProvider)
          .removeStudentFromClass(classId, studentId);
      // Invalidate the list to trigger a refresh
      ref.invalidate(studentsControllerProvider(classId));
    });
  }
}
