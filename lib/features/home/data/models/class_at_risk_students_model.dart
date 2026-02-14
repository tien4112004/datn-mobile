import 'package:AIPrimary/features/home/data/models/at_risk_student_model.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'class_at_risk_students_model.freezed.dart';
part 'class_at_risk_students_model.g.dart';

@freezed
abstract class ClassAtRiskStudentsModel with _$ClassAtRiskStudentsModel {
  const factory ClassAtRiskStudentsModel({
    required String classId,
    required String className,
    required int totalStudents,
    required int atRiskCount,
    required List<AtRiskStudentModel> atRiskStudents,
  }) = _ClassAtRiskStudentsModel;

  factory ClassAtRiskStudentsModel.fromJson(Map<String, dynamic> json) =>
      _$ClassAtRiskStudentsModelFromJson(json);
}
