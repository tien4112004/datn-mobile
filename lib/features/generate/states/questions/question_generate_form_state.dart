import 'package:AIPrimary/features/generate/domain/entity/ai_model.dart';
import 'package:AIPrimary/shared/models/cms_enums.dart';

/// State class representing the question generation form inputs.
class QuestionGenerateFormState {
  final String topic;
  final GradeLevel grade;
  final Subject subject;
  final String? chapter;
  final Set<QuestionType> selectedTypes;
  final Map<Difficulty, int> difficultyCounts;
  final AIModel? selectedModel;
  final String prompt;

  QuestionGenerateFormState({
    this.topic = '',
    this.grade = GradeLevel.grade1,
    this.subject = Subject.mathematics,
    this.chapter,
    Set<QuestionType>? selectedTypes,
    Map<Difficulty, int>? difficultyCounts,
    this.selectedModel,
    this.prompt = '',
  }) : selectedTypes = selectedTypes ?? {QuestionType.multipleChoice},
       difficultyCounts =
           difficultyCounts ?? {for (final d in Difficulty.values) d: 0};

  QuestionGenerateFormState copyWith({
    String? topic,
    GradeLevel? grade,
    bool clearGrade = false,
    Subject? subject,
    bool clearSubject = false,
    String? chapter,
    bool clearChapter = false,
    Set<QuestionType>? selectedTypes,
    Map<Difficulty, int>? difficultyCounts,
    AIModel? selectedModel,
    bool clearSelectedModel = false,
    String? prompt,
  }) {
    return QuestionGenerateFormState(
      topic: topic ?? this.topic,
      grade: clearGrade ? GradeLevel.grade1 : (grade ?? this.grade),
      subject: clearSubject ? Subject.mathematics : (subject ?? this.subject),
      chapter: clearChapter ? null : (chapter ?? this.chapter),
      selectedTypes: selectedTypes ?? Set.from(this.selectedTypes),
      difficultyCounts: difficultyCounts ?? Map.from(this.difficultyCounts),
      selectedModel: clearSelectedModel
          ? null
          : (selectedModel ?? this.selectedModel),
      prompt: prompt ?? this.prompt,
    );
  }

  bool get isValid =>
      topic.trim().isNotEmpty &&
      selectedTypes.isNotEmpty &&
      difficultyCounts.values.any((c) => c > 0);

  int get totalQuestionCount =>
      difficultyCounts.values.fold(0, (a, b) => a + b);

  Map<Difficulty, int> get activeQuestionsPerDifficulty =>
      Map.fromEntries(difficultyCounts.entries.where((e) => e.value > 0));
}
