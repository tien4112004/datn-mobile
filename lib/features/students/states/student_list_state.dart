import 'package:datn_mobile/features/students/domain/entity/student.dart';

/// State class for managing a list of students.
class StudentListState {
  /// The list of students.
  final List<Student> value;

  /// Whether the data has been fetched at least once.
  final bool isFetched;

  /// Whether a request is currently in progress.
  final bool isLoading;

  /// Any error that occurred during fetch.
  final Object? error;

  const StudentListState({
    required this.value,
    required this.isFetched,
    required this.isLoading,
    this.error,
  });

  /// Initial empty state.
  factory StudentListState.initial() => const StudentListState(
    value: [],
    isFetched: false,
    isLoading: false,
    error: null,
  );

  /// Creates a loading state.
  StudentListState loading() => copyWith(isLoading: true, error: null);

  /// Creates a success state with data.
  StudentListState success(List<Student> students) =>
      copyWith(value: students, isFetched: true, isLoading: false, error: null);

  /// Creates an error state.
  StudentListState failure(Object error) =>
      copyWith(isLoading: false, error: error);

  StudentListState copyWith({
    List<Student>? value,
    bool? isFetched,
    bool? isLoading,
    Object? error,
  }) {
    return StudentListState(
      value: value ?? this.value,
      isFetched: isFetched ?? this.isFetched,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}
