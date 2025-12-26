import 'dart:async';

import 'package:datn_mobile/features/classes/data/repository/class_repository_impl.dart';
import 'package:datn_mobile/features/classes/data/source/class_remote_data_source.dart';
import 'package:datn_mobile/features/classes/domain/entity/class_entity.dart';
import 'package:datn_mobile/features/classes/domain/repository/class_repository.dart';
import 'package:datn_mobile/shared/api_client/dio/dio_client_provider.dart';
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
    AsyncNotifierProvider<ClassesController, List<ClassEntity>>(
      () => ClassesController(),
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
