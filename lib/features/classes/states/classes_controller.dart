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

/// Controller for joining a class.
class JoinClassController extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() {
    // Initial state - no operation
  }

  /// Joins a class by join code and refreshes the list.
  Future<void> joinClass({required String joinCode}) async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      final repository = ref.read(classRepositoryProvider);
      await repository.joinClass(joinCode: joinCode);
      // Refresh the classes list
      ref.invalidate(classesControllerProvider);
    });
  }
}
