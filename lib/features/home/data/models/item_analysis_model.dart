import 'package:freezed_annotation/freezed_annotation.dart';

part 'item_analysis_model.freezed.dart';
part 'item_analysis_model.g.dart';

enum QuestionDifficulty {
  @JsonValue('Easy')
  easy,
  @JsonValue('Medium')
  medium,
  @JsonValue('Hard')
  hard,
}

@freezed
abstract class ItemAnalysisModel with _$ItemAnalysisModel {
  const factory ItemAnalysisModel({
    required String assignmentId,
    required String assignmentTitle,
    required int totalSubmissions,
    required List<QuestionAnalysis> questionAnalysis,
    required List<TopicAnalysis> topicAnalysis,
  }) = _ItemAnalysisModel;

  factory ItemAnalysisModel.fromJson(Map<String, dynamic> json) =>
      _$ItemAnalysisModelFromJson(json);
}

@freezed
abstract class QuestionAnalysis with _$QuestionAnalysis {
  const factory QuestionAnalysis({
    required String questionId,
    required String questionTitle,
    required String questionType,
    required double averageScore,
    required double maxPoints,
    required double successRate,
    required int correctCount,
    required int incorrectCount,
    required QuestionDifficulty difficulty,
    Map<String, int>? optionDistribution,
  }) = _QuestionAnalysis;

  factory QuestionAnalysis.fromJson(Map<String, dynamic> json) =>
      _$QuestionAnalysisFromJson(json);
}

@freezed
abstract class TopicAnalysis with _$TopicAnalysis {
  const factory TopicAnalysis({
    required String topicId,
    required String topicName,
    required double averageScore,
    required double successRate,
    required int questionCount,
  }) = _TopicAnalysis;

  factory TopicAnalysis.fromJson(Map<String, dynamic> json) =>
      _$TopicAnalysisFromJson(json);
}
