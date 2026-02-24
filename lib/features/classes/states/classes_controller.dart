part of 'controller_provider.dart';

/// Controller for managing the class list state.
class ClassesController extends AsyncNotifier<List<ClassEntity>> {
  @override
  Future<List<ClassEntity>> build() async {
    return _fetchClasses();
  }

  Future<List<ClassEntity>> _fetchClasses() async {
    final repository = ref.read(classRepositoryProvider);
    return repository.getClasses();
  }

  /// Refreshes the class list.
  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_fetchClasses);
  }
}

class DetailClassController extends AsyncNotifier<ClassEntity> {
  final String classId;

  DetailClassController({required this.classId});

  @override
  Future<ClassEntity> build() async {
    return _fetchClass(classId);
  }

  Future<ClassEntity> _fetchClass(String classId) async {
    final repository = ref.read(classRepositoryProvider);
    return repository.getClassById(classId);
  }
}

/// Controller for creating a new class.
class CreateClassController extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() {
    // Initial state - no operation
  }

  /// Creates a new class and refreshes the list.
  Future<void> createClass({required String name, String? description}) async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      final repository = ref.read(classRepositoryProvider);
      await repository.createClass(name: name, description: description);
      // Refresh the classes list
      ref.invalidate(classesControllerProvider);
    });
  }
}

/// Controller for updating a class.
class UpdateClassController extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() {
    // Initial state - no operation
  }

  /// Updates a class and refreshes the list.
  Future<void> updateClass({
    required String classId,
    String? name,
    String? description,
    String? settings,
    bool? isActive,
  }) async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      final repository = ref.read(classRepositoryProvider);
      await repository.updateClass(
        classId: classId,
        name: name,
        description: description,
        settings: settings,
        isActive: isActive,
      );
      // Refresh the classes list
      ref.invalidate(classesControllerProvider);
    });
  }
}

/// Controller for deleting a class.
class DeleteClassController extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() {
    // Initial state - no operation
  }

  /// Deletes a class and refreshes the list.
  Future<void> deleteClass(String classId) async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      final repository = ref.read(classRepositoryProvider);
      await repository.deleteClass(classId);
      ref.invalidate(classesControllerProvider);
    });
  }
}
