import 'package:datn_mobile/features/students/data/dto/student_create_request_dto.dart';
import 'package:datn_mobile/features/students/data/dto/student_update_request_dto.dart';
import 'package:datn_mobile/features/students/domain/entity/student.dart';
import 'package:datn_mobile/features/students/domain/repository/student_repository.dart';
import 'package:datn_mobile/features/students/domain/service/student_service.dart';
import 'package:datn_mobile/features/students/enum/student_status.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

part 'student_service_impl.dart';
part 'mock_student_service.dart';

/// Provider for the StudentService implementation.
/// Currently using MockStudentService for UI testing.
final studentServiceProvider = Provider<StudentService>((ref) {
  // TODO: Switch back to real implementation when backend is ready
  // return StudentServiceImpl(ref.read(studentRepositoryProvider));
  return MockStudentService();
});
