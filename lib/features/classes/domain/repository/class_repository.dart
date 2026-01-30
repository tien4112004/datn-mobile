import 'package:AIPrimary/features/classes/domain/entity/class_entity.dart';

/// Repository interface for class data operations.
abstract class ClassRepository {
  /// Fetches list of classes for the current user.
  Future<List<ClassEntity>> getClasses({
    int page = 1,
    int pageSize = 20,
    String? search,
    String? sort,
    bool? isActive,
  });

  /// Creates a new class.
  Future<ClassEntity> createClass({
    required String name,
    String? description,
    String? settings,
  });

  /// Joins an existing class by join code.
  Future<ClassEntity> joinClass({required String joinCode});

  /// Gets a single class by ID.
  Future<ClassEntity> getClassById(String classId);

  /// Updates an existing class.
  Future<ClassEntity> updateClass({
    required String classId,
    String? name,
    String? description,
    String? settings,
    bool? isActive,
  });
}
