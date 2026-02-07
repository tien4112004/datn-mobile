import 'package:flutter/material.dart';
import 'package:AIPrimary/features/questions/domain/entity/question_entity.dart';
import 'package:AIPrimary/features/questions/domain/entity/answer_entity.dart';
import 'package:AIPrimary/shared/models/cms_enums.dart';

// Multiple Choice modes
import 'package:AIPrimary/features/questions/ui/widgets/multiple_choice/multiple_choice_editing.dart';
import 'package:AIPrimary/features/questions/ui/widgets/multiple_choice/multiple_choice_viewing.dart';
import 'package:AIPrimary/features/questions/ui/widgets/multiple_choice/multiple_choice_doing.dart';
import 'package:AIPrimary/features/questions/ui/widgets/multiple_choice/multiple_choice_submitted.dart';
import 'package:AIPrimary/features/questions/ui/widgets/multiple_choice/multiple_choice_after_assess.dart';
import 'package:AIPrimary/features/questions/ui/widgets/multiple_choice/multiple_choice_grading.dart';

// Fill in Blank modes
import 'package:AIPrimary/features/questions/ui/widgets/fill_in_blank/fill_in_blank_editing.dart';
import 'package:AIPrimary/features/questions/ui/widgets/fill_in_blank/fill_in_blank_viewing.dart';
import 'package:AIPrimary/features/questions/ui/widgets/fill_in_blank/fill_in_blank_doing.dart';
import 'package:AIPrimary/features/questions/ui/widgets/fill_in_blank/fill_in_blank_submitted.dart';
import 'package:AIPrimary/features/questions/ui/widgets/fill_in_blank/fill_in_blank_after_assess.dart';
import 'package:AIPrimary/features/questions/ui/widgets/fill_in_blank/fill_in_blank_grading.dart';

// Matching modes
import 'package:AIPrimary/features/questions/ui/widgets/matching/matching_editing.dart';
import 'package:AIPrimary/features/questions/ui/widgets/matching/matching_viewing.dart';
import 'package:AIPrimary/features/questions/ui/widgets/matching/matching_doing.dart';
import 'package:AIPrimary/features/questions/ui/widgets/matching/matching_submitted.dart';
import 'package:AIPrimary/features/questions/ui/widgets/matching/matching_after_assess.dart';
import 'package:AIPrimary/features/questions/ui/widgets/matching/matching_grading.dart';

// Open Ended modes
import 'package:AIPrimary/features/questions/ui/widgets/open_ended/open_ended_editing.dart';
import 'package:AIPrimary/features/questions/ui/widgets/open_ended/open_ended_viewing.dart';
import 'package:AIPrimary/features/questions/ui/widgets/open_ended/open_ended_doing.dart';
import 'package:AIPrimary/features/questions/ui/widgets/open_ended/open_ended_submitted.dart';
import 'package:AIPrimary/features/questions/ui/widgets/open_ended/open_ended_after_assess.dart';
import 'package:AIPrimary/features/questions/ui/widgets/open_ended/open_ended_grading.dart';

/// Unified question renderer that routes to the correct mode-specific widget
/// based on [question.type] and [mode].
///
/// This mirrors the FE's QuestionRenderer component.
class QuestionRenderer extends StatelessWidget {
  final BaseQuestion question;
  final QuestionMode mode;
  final QuestionAnswer? answer;
  final double? points;
  final int? number;
  final bool showHeader;

  /// Callback for editing mode — returns updated question
  final Function(BaseQuestion)? onQuestionChange;

  /// Callback for doing mode — returns updated answer
  final Function(QuestionAnswer)? onAnswerChange;

  /// Callback for grading mode — returns points and optional feedback
  final Function(double points, String? feedback)? onGradeChange;

  const QuestionRenderer({
    super.key,
    required this.question,
    required this.mode,
    this.answer,
    this.points,
    this.number,
    this.showHeader = true,
    this.onQuestionChange,
    this.onAnswerChange,
    this.onGradeChange,
  });

  @override
  Widget build(BuildContext context) {
    switch (question.type) {
      case QuestionType.multipleChoice:
        return _buildMultipleChoice(question as MultipleChoiceQuestion);
      case QuestionType.fillInBlank:
        return _buildFillInBlank(question as FillInBlankQuestion);
      case QuestionType.matching:
        return _buildMatching(question as MatchingQuestion);
      case QuestionType.openEnded:
        return _buildOpenEnded(question as OpenEndedQuestion);
    }
  }

  // ---------------------------------------------------------------------------
  // Multiple Choice
  // ---------------------------------------------------------------------------

  Widget _buildMultipleChoice(MultipleChoiceQuestion q) {
    final mcAnswer = answer as MultipleChoiceAnswer?;

    switch (mode) {
      case QuestionMode.editing:
        return MultipleChoiceEditing(
          question: q,
          onUpdate: onQuestionChange != null
              ? (updated) => onQuestionChange!(updated)
              : null,
        );
      case QuestionMode.viewing:
        return MultipleChoiceViewing(question: q, showHeader: showHeader);
      case QuestionMode.doing:
        return MultipleChoiceDoing(
          question: q,
          selectedAnswer: mcAnswer?.selectedOptionId,
          onAnswerSelected: onAnswerChange != null
              ? (optionId) => onAnswerChange!(
                  MultipleChoiceAnswer(
                    questionId: q.id,
                    selectedOptionId: optionId,
                  ),
                )
              : null,
        );
      case QuestionMode.submitted:
        return MultipleChoiceSubmitted(
          question: q,
          selectedAnswer: mcAnswer?.selectedOptionId,
          showHeader: showHeader,
        );
      case QuestionMode.afterAssess:
        return MultipleChoiceAfterAssess(
          question: q,
          studentAnswer: mcAnswer?.selectedOptionId,
        );
      case QuestionMode.grading:
        return MultipleChoiceGrading(
          question: q,
          studentAnswer: mcAnswer?.selectedOptionId,
        );
    }
  }

  // ---------------------------------------------------------------------------
  // Fill in Blank
  // ---------------------------------------------------------------------------

  Widget _buildFillInBlank(FillInBlankQuestion q) {
    final fibAnswer = answer as FillInBlankAnswer?;

    switch (mode) {
      case QuestionMode.editing:
        return FillInBlankEditing(
          question: q,
          onUpdate: onQuestionChange != null
              ? (updated) => onQuestionChange!(updated)
              : null,
        );
      case QuestionMode.viewing:
        return FillInBlankViewing(question: q, showHeader: showHeader);
      case QuestionMode.doing:
        return FillInBlankDoing(
          question: q,
          answers: fibAnswer?.blanks,
          onAnswersChanged: onAnswerChange != null
              ? (blanks) => onAnswerChange!(
                  FillInBlankAnswer(questionId: q.id, blanks: blanks),
                )
              : null,
        );
      case QuestionMode.submitted:
        return FillInBlankSubmitted(
          question: q,
          studentAnswers: fibAnswer?.blanks,
          showHeader: showHeader,
        );
      case QuestionMode.afterAssess:
        return FillInBlankAfterAssess(
          question: q,
          studentAnswers: fibAnswer?.blanks,
        );
      case QuestionMode.grading:
        return FillInBlankGrading(
          question: q,
          studentAnswers: fibAnswer?.blanks,
        );
    }
  }

  // ---------------------------------------------------------------------------
  // Matching
  // ---------------------------------------------------------------------------

  Widget _buildMatching(MatchingQuestion q) {
    final matchAnswer = answer as MatchingAnswer?;

    switch (mode) {
      case QuestionMode.editing:
        return MatchingEditing(
          question: q,
          onUpdate: onQuestionChange != null
              ? (updated) => onQuestionChange!(updated)
              : null,
        );
      case QuestionMode.viewing:
        return MatchingViewing(question: q, showHeader: showHeader);
      case QuestionMode.doing:
        return MatchingDoing(
          question: q,
          answers: matchAnswer?.matches,
          onAnswersChanged: onAnswerChange != null
              ? (matches) => onAnswerChange!(
                  MatchingAnswer(questionId: q.id, matches: matches),
                )
              : null,
        );
      case QuestionMode.submitted:
        return MatchingSubmitted(
          question: q,
          studentAnswers: matchAnswer?.matches,
          showHeader: showHeader,
        );
      case QuestionMode.afterAssess:
        return MatchingAfterAssess(
          question: q,
          studentAnswers: matchAnswer?.matches,
        );
      case QuestionMode.grading:
        return MatchingGrading(
          question: q,
          studentAnswers: matchAnswer?.matches,
        );
    }
  }

  // ---------------------------------------------------------------------------
  // Open Ended
  // ---------------------------------------------------------------------------

  Widget _buildOpenEnded(OpenEndedQuestion q) {
    final oeAnswer = answer as OpenEndedAnswer?;

    switch (mode) {
      case QuestionMode.editing:
        return OpenEndedEditing(
          question: q,
          onUpdate: onQuestionChange != null
              ? (updated) => onQuestionChange!(updated)
              : null,
        );
      case QuestionMode.viewing:
        return OpenEndedViewing(question: q, showHeader: showHeader);
      case QuestionMode.doing:
        return OpenEndedDoing(
          question: q,
          answer: oeAnswer?.text,
          onAnswerChanged: onAnswerChange != null
              ? (text) => onAnswerChange!(
                  OpenEndedAnswer(questionId: q.id, text: text),
                )
              : null,
        );
      case QuestionMode.submitted:
        return OpenEndedSubmitted(
          question: q,
          studentAnswer: oeAnswer?.text,
          showHeader: showHeader,
        );
      case QuestionMode.afterAssess:
        return OpenEndedAfterAssess(question: q, studentAnswer: oeAnswer?.text);
      case QuestionMode.grading:
        return OpenEndedGrading(
          question: q,
          studentAnswer: oeAnswer?.text,
          onScoreChanged: onGradeChange != null
              ? (score) => onGradeChange!(score.toDouble(), null)
              : null,
        );
    }
  }
}
