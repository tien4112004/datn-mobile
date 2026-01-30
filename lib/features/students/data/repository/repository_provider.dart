import 'dart:io';

import 'package:AIPrimary/features/students/data/dto/student_create_request_dto.dart';
import 'package:AIPrimary/features/students/data/dto/student_import_response_dto.dart';
import 'package:AIPrimary/features/students/data/dto/student_response_dto.dart';
import 'package:AIPrimary/features/students/data/dto/student_update_request_dto.dart';
import 'package:AIPrimary/features/students/data/source/students_remote_source.dart';
import 'package:AIPrimary/features/students/data/source/students_remote_source_provider.dart';
import 'package:AIPrimary/features/students/domain/entity/student.dart';
import 'package:AIPrimary/features/students/domain/entity/student_import_result.dart';
import 'package:AIPrimary/features/students/domain/repository/student_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

part 'student_repository_impl.dart';

/// Provider for the StudentRepository implementation.
final studentRepositoryProvider = Provider<StudentRepository>(
  (ref) => StudentRepositoryImpl(ref.read(studentsRemoteSourceProvider)),
);
