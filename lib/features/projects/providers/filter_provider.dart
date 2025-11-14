import 'package:flutter_riverpod/flutter_riverpod.dart';

class FilterState {
  final String? subject;
  final String? grade;

  FilterState({this.subject, this.grade});

  FilterState copyWith({String? subject, String? grade}) {
    return FilterState(
      subject: subject ?? this.subject,
      grade: grade ?? this.grade,
    );
  }

  bool get hasActiveFilters => subject != null || grade != null;
}

class FilterNotifier extends Notifier<FilterState> {
  @override
  FilterState build() {
    return FilterState();
  }

  void setSubject(String? subject) {
    state = state.copyWith(subject: subject);
  }

  void setGrade(String? grade) {
    state = state.copyWith(grade: grade);
  }

  void clearFilters() {
    state = FilterState();
  }

  void clearSubject() {
    state = state.copyWith(subject: null);
  }

  void clearGrade() {
    state = state.copyWith(grade: null);
  }
}

final filterProvider = NotifierProvider<FilterNotifier, FilterState>(
  () => FilterNotifier(),
);
