import 'package:datn_mobile/features/students/data/dto/student_create_request_dto.dart';
import 'package:datn_mobile/features/students/data/dto/student_update_request_dto.dart';
import 'package:datn_mobile/features/students/data/repository/repository_provider.dart';
import 'package:datn_mobile/features/students/domain/entity/student.dart';
import 'package:datn_mobile/features/students/states/student_list_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

part 'students_controller.dart';

/// Provider for students list by class ID.
/// Uses family pattern so each class has its own cached state.
final studentsControllerProvider =
    AsyncNotifierProvider.family<StudentsController, StudentListState, String>(
      (classId) => StudentsController(classId: classId),
    );

/// Provider to fetch a single student by ID.
final studentByIdProvider = FutureProvider.family<Student, String>((
  ref,
  id,
) async {
  return ref.read(studentRepositoryProvider).getStudentById(id);
});

/// Provider for creating a new student.
final createStudentControllerProvider =
    AsyncNotifierProvider<CreateStudentController, void>(
      () => CreateStudentController(),
    );

/// Provider for updating a student.
final updateStudentControllerProvider =
    AsyncNotifierProvider<UpdateStudentController, void>(
      () => UpdateStudentController(),
    );

/// Provider for removing a student.
final removeStudentControllerProvider =
    AsyncNotifierProvider<RemoveStudentController, void>(
      () => RemoveStudentController(),
    );
