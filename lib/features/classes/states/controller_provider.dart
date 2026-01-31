import 'dart:async';

import 'package:AIPrimary/features/classes/data/repository/class_repository_impl.dart';
import 'package:AIPrimary/features/classes/data/source/class_remote_data_source.dart';
import 'package:AIPrimary/features/classes/domain/entity/class_entity.dart';
import 'package:AIPrimary/features/classes/domain/repository/class_repository.dart';
import 'package:AIPrimary/shared/api_client/dio/dio_client_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

part 'classes_controller.dart';

/// Provider for the class remote data source.
final classRemoteDataSourceProvider = Provider<ClassRemoteDataSource>((ref) {
  final dio = ref.watch(dioPod);
  return ClassRemoteDataSource(dio);
});

/// Provider for the class repository.
final classRepositoryProvider = Provider<ClassRepository>((ref) {
  final dataSource = ref.watch(classRemoteDataSourceProvider);
  return ClassRepositoryImpl(dataSource);
});

/// Provider for classes list controller.
final classesControllerProvider =
    AsyncNotifierProvider.autoDispose<ClassesController, List<ClassEntity>>(
      () => ClassesController(),
    );

/// Provider for detail class controller.
final detailClassControllerProvider =
    AsyncNotifierProvider.family<DetailClassController, ClassEntity, String>(
      (String classId) => DetailClassController(classId: classId),
    );

/// Provider for creating a new class.
final createClassControllerProvider =
    AsyncNotifierProvider<CreateClassController, void>(
      () => CreateClassController(),
    );

/// Provider for joining a class.
final joinClassControllerProvider =
    AsyncNotifierProvider<JoinClassController, void>(
      () => JoinClassController(),
    );

/// Provider for updating a class.
final updateClassControllerProvider =
    AsyncNotifierProvider<UpdateClassController, void>(
      () => UpdateClassController(),
    );
