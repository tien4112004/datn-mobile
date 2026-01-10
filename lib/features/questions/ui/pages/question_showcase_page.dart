import 'package:auto_route/auto_route.dart';
import 'package:datn_mobile/shared/widgets/custom_app_bar.dart';
import 'package:datn_mobile/shared/widget/flex_dropdown_field.dart';
import 'package:flutter/material.dart';
import 'package:datn_mobile/features/questions/domain/entity/question_entity.dart';
import 'package:datn_mobile/features/questions/domain/entity/question_enums.dart';

// Multiple Choice Widgets
import 'package:datn_mobile/features/questions/ui/widgets/multiple_choice/multiple_choice_editing.dart';
import 'package:datn_mobile/features/questions/ui/widgets/multiple_choice/multiple_choice_doing.dart';
import 'package:datn_mobile/features/questions/ui/widgets/multiple_choice/multiple_choice_viewing.dart';
import 'package:datn_mobile/features/questions/ui/widgets/multiple_choice/multiple_choice_grading.dart';
import 'package:datn_mobile/features/questions/ui/widgets/multiple_choice/multiple_choice_after_assess.dart';

// Matching Widgets
import 'package:datn_mobile/features/questions/ui/widgets/matching/matching_doing.dart';
import 'package:datn_mobile/features/questions/ui/widgets/matching/matching_viewing.dart';
import 'package:datn_mobile/features/questions/ui/widgets/matching/matching_editing.dart';
import 'package:datn_mobile/features/questions/ui/widgets/matching/matching_grading.dart';
import 'package:datn_mobile/features/questions/ui/widgets/matching/matching_after_assess.dart';

// Fill in Blank Widgets
import 'package:datn_mobile/features/questions/ui/widgets/fill_in_blank/fill_in_blank_doing.dart';
import 'package:datn_mobile/features/questions/ui/widgets/fill_in_blank/fill_in_blank_viewing.dart';
import 'package:datn_mobile/features/questions/ui/widgets/fill_in_blank/fill_in_blank_editing.dart';
import 'package:datn_mobile/features/questions/ui/widgets/fill_in_blank/fill_in_blank_grading.dart';
import 'package:datn_mobile/features/questions/ui/widgets/fill_in_blank/fill_in_blank_after_assess.dart';

// Open Ended Widgets
import 'package:datn_mobile/features/questions/ui/widgets/open_ended/open_ended_doing.dart';
import 'package:datn_mobile/features/questions/ui/widgets/open_ended/open_ended_grading.dart';
import 'package:datn_mobile/features/questions/ui/widgets/open_ended/open_ended_editing.dart';
import 'package:datn_mobile/features/questions/ui/widgets/open_ended/open_ended_viewing.dart';
import 'package:datn_mobile/features/questions/ui/widgets/open_ended/open_ended_after_assess.dart';

@RoutePage()
class QuestionShowcasePage extends StatefulWidget {
  const QuestionShowcasePage({super.key});

  @override
  State<QuestionShowcasePage> createState() => _QuestionShowcasePageState();
}

class _QuestionShowcasePageState extends State<QuestionShowcasePage> {
  QuestionType _selectedType = QuestionType.multipleChoice;
  QuestionMode _selectedMode = QuestionMode.doing;

  // Sample data
  late MultipleChoiceQuestion _mcQuestion;
  late MatchingQuestion _matchingQuestion;
  late FillInBlankQuestion _fillInBlankQuestion;
  late OpenEndedQuestion _openEndedQuestion;

  @override
  void initState() {
    super.initState();
    _initSampleQuestions();
  }

  void _initSampleQuestions() {
    // Multiple Choice Sample
    _mcQuestion = const MultipleChoiceQuestion(
      id: '1',
      difficulty: Difficulty.medium,
      title: 'What is the capital of France?',
      explanation: 'Paris is the capital and largest city of France.',
      points: 10,
      data: MultipleChoiceData(
        options: [
          MultipleChoiceOption(id: 'a', text: 'London', isCorrect: false),
          MultipleChoiceOption(id: 'b', text: 'Paris', isCorrect: true),
          MultipleChoiceOption(id: 'c', text: 'Berlin', isCorrect: false),
          MultipleChoiceOption(id: 'd', text: 'Madrid', isCorrect: false),
        ],
      ),
    );

    // Matching Sample
    _matchingQuestion = const MatchingQuestion(
      id: '2',
      difficulty: Difficulty.easy,
      title: 'Match the countries with their capitals:',
      points: 15,
      data: MatchingData(
        pairs: [
          MatchingPair(id: '1', left: 'Japan', right: 'Tokyo'),
          MatchingPair(id: '2', left: 'Italy', right: 'Rome'),
          MatchingPair(id: '3', left: 'Egypt', right: 'Cairo'),
        ],
      ),
    );

    // Fill in Blank Sample
    _fillInBlankQuestion = const FillInBlankQuestion(
      id: '3',
      difficulty: Difficulty.medium,
      title: 'Complete the sentence:',
      points: 12,
      data: FillInBlankData(
        segments: [
          BlankSegment(id: 't1', type: SegmentType.text, content: 'The'),
          BlankSegment(
            id: 'b1',
            type: SegmentType.blank,
            content: 'sun',
            acceptableAnswers: ['Sun', 'sun'],
          ),
          BlankSegment(
            id: 't2',
            type: SegmentType.text,
            content: 'rises in the',
          ),
          BlankSegment(
            id: 'b2',
            type: SegmentType.blank,
            content: 'east',
            acceptableAnswers: ['East', 'east'],
          ),
          BlankSegment(
            id: 't3',
            type: SegmentType.text,
            content: 'and sets in the',
          ),
          BlankSegment(
            id: 'b3',
            type: SegmentType.blank,
            content: 'west',
            acceptableAnswers: ['West', 'west'],
          ),
        ],
      ),
    );

    // Open Ended Sample
    _openEndedQuestion = const OpenEndedQuestion(
      id: '4',
      difficulty: Difficulty.hard,
      title: 'Explain the water cycle in your own words.',
      points: 20,
      data: OpenEndedData(
        expectedAnswer:
            'The water cycle is the continuous movement of water '
            'on, above, and below the surface of the Earth. It involves '
            'evaporation, condensation, precipitation, and collection.',
        maxLength: 500,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: const CustomAppBar(title: 'Question Widgets Showcase'),
      body: Column(
        children: [
          // Controls
          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Column(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Question Type',
                          style: theme.textTheme.labelMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        FlexDropdownField<QuestionType>(
                          value: _selectedType,
                          items: QuestionType.values,
                          itemLabelBuilder: (type) => type.displayName,
                          onChanged: (value) {
                            setState(() {
                              _selectedType = value;
                            });
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Mode',
                          style: theme.textTheme.labelMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        FlexDropdownField<QuestionMode>(
                          value: _selectedMode,
                          items: _getAvailableModes(),
                          itemLabelBuilder: (mode) => mode.displayName,
                          onChanged: (value) {
                            setState(() {
                              _selectedMode = value;
                            });
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          // Question Display
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: _buildQuestionWidget(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<QuestionMode> _getAvailableModes() {
    // Return available modes based on question type
    // All question types now support all 5 modes
    return QuestionMode.values;
  }

  Widget _buildQuestionWidget() {
    switch (_selectedType) {
      case QuestionType.multipleChoice:
        return _buildMultipleChoiceWidget();
      case QuestionType.matching:
        return _buildMatchingWidget();
      case QuestionType.fillInBlank:
        return _buildFillInBlankWidget();
      case QuestionType.openEnded:
        return _buildOpenEndedWidget();
    }
  }

  Widget _buildMultipleChoiceWidget() {
    switch (_selectedMode) {
      case QuestionMode.editing:
        return MultipleChoiceEditing(question: _mcQuestion);
      case QuestionMode.doing:
        return MultipleChoiceDoing(question: _mcQuestion, selectedAnswer: null);
      case QuestionMode.viewing:
        return MultipleChoiceViewing(question: _mcQuestion);
      case QuestionMode.grading:
        return MultipleChoiceGrading(
          question: _mcQuestion,
          studentAnswer: 'a', // Wrong answer for demo
        );
      case QuestionMode.afterAssess:
        return MultipleChoiceAfterAssess(
          question: _mcQuestion,
          studentAnswer: 'b', // Correct answer for demo
        );
    }
  }

  Widget _buildMatchingWidget() {
    switch (_selectedMode) {
      case QuestionMode.editing:
        return MatchingEditing(question: _matchingQuestion);
      case QuestionMode.doing:
        return MatchingDoing(question: _matchingQuestion);
      case QuestionMode.viewing:
        return MatchingViewing(question: _matchingQuestion);
      case QuestionMode.grading:
        return MatchingGrading(
          question: _matchingQuestion,
          studentAnswers: {
            'Japan': 'Rome', // Wrong answer for demo
            'Italy': 'Rome', // Correct
            'Egypt': 'Cairo', // Correct
          },
        );
      case QuestionMode.afterAssess:
        return MatchingAfterAssess(
          question: _matchingQuestion,
          studentAnswers: {
            'Japan': 'Tokyo', // Correct
            'Italy': 'Cairo', // Wrong
            'Egypt': 'Cairo', // Correct
          },
        );
    }
  }

  Widget _buildFillInBlankWidget() {
    switch (_selectedMode) {
      case QuestionMode.editing:
        return FillInBlankEditing(question: _fillInBlankQuestion);
      case QuestionMode.doing:
        return FillInBlankDoing(question: _fillInBlankQuestion);
      case QuestionMode.viewing:
        return FillInBlankViewing(question: _fillInBlankQuestion);
      case QuestionMode.grading:
        return FillInBlankGrading(
          question: _fillInBlankQuestion,
          studentAnswers: {
            'b1': 'moon', // Wrong
            'b2': 'east', // Correct
            'b3': 'west', // Correct
          },
        );
      case QuestionMode.afterAssess:
        return FillInBlankAfterAssess(
          question: _fillInBlankQuestion,
          studentAnswers: {
            'b1': 'sun', // Correct
            'b2': 'west', // Wrong
            'b3': 'west', // Correct
          },
        );
    }
  }

  Widget _buildOpenEndedWidget() {
    switch (_selectedMode) {
      case QuestionMode.editing:
        return OpenEndedEditing(question: _openEndedQuestion);
      case QuestionMode.doing:
        return OpenEndedDoing(question: _openEndedQuestion);
      case QuestionMode.viewing:
        return OpenEndedViewing(question: _openEndedQuestion);
      case QuestionMode.grading:
        return OpenEndedGrading(
          question: _openEndedQuestion,
          studentAnswer:
              'The water cycle involves water moving around the Earth through evaporation and rain.',
          score: null,
        );
      case QuestionMode.afterAssess:
        return OpenEndedAfterAssess(
          question: _openEndedQuestion,
          studentAnswer:
              'Water evaporates from oceans and lakes, forms clouds, falls as rain, and returns to bodies of water.',
          score: 15, // Out of 20 points
        );
    }
  }
}
