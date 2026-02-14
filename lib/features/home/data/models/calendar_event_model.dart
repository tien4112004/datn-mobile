import 'package:freezed_annotation/freezed_annotation.dart';

part 'calendar_event_model.freezed.dart';
part 'calendar_event_model.g.dart';

enum CalendarEventType {
  @JsonValue('DEADLINE')
  deadline,
  @JsonValue('GRADING_REMINDER')
  gradingReminder,
  @JsonValue('SCHEDULED_POST')
  scheduledPost,
  @JsonValue('ASSIGNMENT_RETURNED')
  assignmentReturned,
}

enum CalendarEventStatus {
  @JsonValue('upcoming')
  upcoming,
  @JsonValue('due-soon')
  dueSoon,
  @JsonValue('overdue')
  overdue,
  @JsonValue('pending')
  pending,
  @JsonValue('completed')
  completed,
  @JsonValue('submitted')
  submitted,
}

@freezed
abstract class CalendarEventModel with _$CalendarEventModel {
  const factory CalendarEventModel({
    required String id,
    required String title,
    required CalendarEventType type,
    required DateTime date,
    required String classId,
    required String className,
    required String relatedId,
    String? description,
    CalendarEventStatus? status,
  }) = _CalendarEventModel;

  factory CalendarEventModel.fromJson(Map<String, dynamic> json) =>
      _$CalendarEventModelFromJson(json);
}
