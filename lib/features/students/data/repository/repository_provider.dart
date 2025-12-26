import 'package:datn_mobile/features/students/data/dto/student_create_request_dto.dart';
import 'package:datn_mobile/features/students/data/dto/student_response_dto.dart';
import 'package:datn_mobile/features/students/data/dto/student_update_request_dto.dart';
import 'package:datn_mobile/features/students/data/source/students_remote_source.dart';
import 'package:datn_mobile/features/students/data/source/students_remote_source_provider.dart';
import 'package:datn_mobile/features/students/domain/entity/student.dart';
import 'package:datn_mobile/features/students/domain/repository/student_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

part 'student_repository_impl.dart';

/// Provider for the StudentRepository implementation.
final studentRepositoryProvider = Provider<StudentRepository>(
  (ref) => StudentRepositoryImpl(ref.read(studentsRemoteSourceProvider)),
);
