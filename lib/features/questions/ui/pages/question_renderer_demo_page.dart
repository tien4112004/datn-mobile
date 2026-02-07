import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:AIPrimary/features/questions/domain/entity/question_entity.dart';
import 'package:AIPrimary/features/questions/domain/entity/answer_entity.dart';
import 'package:AIPrimary/features/questions/ui/widgets/question_renderer.dart';
import 'package:AIPrimary/shared/models/cms_enums.dart';

// ---------------------------------------------------------------------------
// Sample Questions (mirrors FE demo data)
// ---------------------------------------------------------------------------

const _multipleChoiceQuestion = MultipleChoiceQuestion(
  id: 'mc-1',
  difficulty: Difficulty.knowledge,
  title: 'What is the capital of Vietnam?',
  explanation:
      'Hanoi has been the capital of Vietnam since 1010 (under the Ly dynasty) and again from 1954.',
  data: MultipleChoiceData(
    options: [
      MultipleChoiceOption(
        id: 'mc-1-a',
        text: 'Ho Chi Minh City',
        isCorrect: false,
      ),
      MultipleChoiceOption(id: 'mc-1-b', text: 'Hanoi', isCorrect: true),
      MultipleChoiceOption(id: 'mc-1-c', text: 'Da Nang', isCorrect: false),
      MultipleChoiceOption(id: 'mc-1-d', text: 'Hue', isCorrect: false),
    ],
    shuffleOptions: false,
  ),
);

const _matchingQuestion = MatchingQuestion(
  id: 'match-1',
  difficulty: Difficulty.comprehension,
  title: 'Match the famous Vietnamese landmarks with their cities',
  explanation: 'These are some of the most iconic landmarks in Vietnam.',
  data: MatchingData(
    pairs: [
      MatchingPair(id: 'pair-1', left: 'Ho Chi Minh Mausoleum', right: 'Hanoi'),
      MatchingPair(
        id: 'pair-2',
        left: 'Notre-Dame Cathedral',
        right: 'Ho Chi Minh City',
      ),
      MatchingPair(id: 'pair-3', left: 'Golden Bridge', right: 'Da Nang'),
      MatchingPair(id: 'pair-4', left: 'Imperial City', right: 'Hue'),
    ],
    shufflePairs: false,
  ),
);

const _openEndedQuestion = OpenEndedQuestion(
  id: 'oe-1',
  difficulty: Difficulty.application,
  title:
      'Explain the significance of the Battle of Dien Bien Phu in Vietnamese history.',
  explanation:
      'The Battle of Dien Bien Phu (1954) was a decisive victory for the Viet Minh over French colonial forces, leading to the end of French Indochina and Vietnamese independence.',
  data: OpenEndedData(
    expectedAnswer:
        'The Battle of Dien Bien Phu was a crucial military victory that led to French withdrawal from Indochina and Vietnamese independence.',
    maxLength: 500,
  ),
);

const _fillInBlankQuestion = FillInBlankQuestion(
  id: 'fib-1',
  difficulty: Difficulty.knowledge,
  title: 'Complete the sentence about Vietnam',
  explanation: 'These are basic facts about Vietnam.',
  data: FillInBlankData(
    segments: [
      BlankSegment(
        id: 'seg-1',
        type: SegmentType.text,
        content: 'Vietnam is located in ',
      ),
      BlankSegment(
        id: 'seg-2',
        type: SegmentType.blank,
        content: 'Southeast Asia',
        acceptableAnswers: ['southeast asia', 'South East Asia'],
      ),
      BlankSegment(
        id: 'seg-3',
        type: SegmentType.text,
        content: ' and its currency is the ',
      ),
      BlankSegment(
        id: 'seg-4',
        type: SegmentType.blank,
        content: 'dong',
        acceptableAnswers: ['Dong', 'VND'],
      ),
      BlankSegment(id: 'seg-5', type: SegmentType.text, content: '.'),
    ],
    caseSensitive: false,
  ),
);

// Sample Answers
const _multipleChoiceAnswer = MultipleChoiceAnswer(
  questionId: 'mc-1',
  selectedOptionId: 'mc-1-b',
);

const _matchingAnswer = MatchingAnswer(
  questionId: 'match-1',
  matches: {
    'pair-1': 'pair-1',
    'pair-2': 'pair-2',
    'pair-3': 'pair-3',
    'pair-4': 'pair-4',
  },
);

const _openEndedAnswer = OpenEndedAnswer(
  questionId: 'oe-1',
  text:
      'The Battle of Dien Bien Phu was a significant military victory for Vietnam that led to independence from France.',
);

const _fillInBlankAnswer = FillInBlankAnswer(
  questionId: 'fib-1',
  blanks: {'seg-2': 'Southeast Asia', 'seg-4': 'dong'},
);

// ---------------------------------------------------------------------------
// Demo Page
// ---------------------------------------------------------------------------

@RoutePage()
class QuestionRendererDemoPage extends StatefulWidget {
  const QuestionRendererDemoPage({super.key});

  @override
  State<QuestionRendererDemoPage> createState() =>
      _QuestionRendererDemoPageState();
}

class _QuestionRendererDemoPageState extends State<QuestionRendererDemoPage> {
  QuestionMode _selectedMode = QuestionMode.doing;
  int _selectedQuestionIndex = 0;

  late List<BaseQuestion> _questions;
  late List<QuestionAnswer> _answers;
  late QuestionAnswer _currentAnswer;

  static const _modeDescriptions = {
    QuestionMode.editing: 'Teacher creates/edits questions',
    QuestionMode.viewing: 'Read-only preview with correct answers',
    QuestionMode.doing: 'Student actively answering',
    QuestionMode.submitted: 'Read-only submitted answers (no feedback)',
    QuestionMode.afterAssess: 'Student review with correct answers',
    QuestionMode.grading: 'Teacher reviewing/grading',
  };

  @override
  void initState() {
    super.initState();
    _questions = [
      _multipleChoiceQuestion,
      _matchingQuestion,
      _openEndedQuestion,
      _fillInBlankQuestion,
    ];
    _answers = [
      _multipleChoiceAnswer,
      _matchingAnswer,
      _openEndedAnswer,
      _fillInBlankAnswer,
    ];
    _currentAnswer = _answers[0];
  }

  void _selectQuestion(int index) {
    setState(() {
      _selectedQuestionIndex = index;
      _currentAnswer = _answers[index];
    });
  }

  void _selectMode(QuestionMode mode) {
    setState(() {
      _selectedMode = mode;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final currentQuestion = _questions[_selectedQuestionIndex];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Question Renderer Demo'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.router.maybePop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ---- Mode Selector ----
            Text(
              'View Mode',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: QuestionMode.values.map((mode) {
                final isSelected = _selectedMode == mode;
                return ChoiceChip(
                  label: Text(mode.displayName),
                  selected: isSelected,
                  onSelected: (_) => _selectMode(mode),
                  selectedColor: colorScheme.primaryContainer,
                  labelStyle: TextStyle(
                    color: isSelected
                        ? colorScheme.onPrimaryContainer
                        : colorScheme.onSurfaceVariant,
                    fontWeight: isSelected
                        ? FontWeight.w600
                        : FontWeight.normal,
                  ),
                );
              }).toList(),
            ),

            // Mode description
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 16,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _modeDescriptions[_selectedMode] ?? '',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ---- Question Type Selector ----
            Text(
              'Question Type',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 48,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _questions.length,
                separatorBuilder: (_, _) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final q = _questions[index];
                  final isSelected = _selectedQuestionIndex == index;
                  return FilterChip(
                    avatar: Icon(
                      QuestionType.getIcon(q.type),
                      size: 18,
                      color: isSelected
                          ? colorScheme.onPrimaryContainer
                          : colorScheme.onSurfaceVariant,
                    ),
                    label: Text(q.type.displayName),
                    selected: isSelected,
                    onSelected: (_) => _selectQuestion(index),
                    selectedColor: colorScheme.primaryContainer,
                    labelStyle: TextStyle(
                      color: isSelected
                          ? colorScheme.onPrimaryContainer
                          : colorScheme.onSurfaceVariant,
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.normal,
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 16),

            // ---- Status Bar ----
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Row(
                children: [
                  _buildInfoChip(
                    'Type: ${currentQuestion.type.displayName}',
                    Colors.blue,
                    theme,
                  ),
                  const SizedBox(width: 8),
                  _buildInfoChip(
                    'Mode: ${_selectedMode.displayName}',
                    Colors.purple,
                    theme,
                  ),
                  const SizedBox(width: 8),
                  _buildInfoChip(
                    currentQuestion.difficulty.displayName,
                    Difficulty.getDifficultyColor(currentQuestion.difficulty),
                    theme,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ---- Question Renderer ----
            Text(
              'Preview',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: colorScheme.outlineVariant),
                borderRadius: BorderRadius.circular(16),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: QuestionRenderer(
                  question: currentQuestion,
                  mode: _selectedMode,
                  answer: _currentAnswer,
                  points: 10,
                  onQuestionChange: (updated) {
                    setState(() {
                      _questions[_selectedQuestionIndex] = updated;
                    });
                  },
                  onAnswerChange: (updated) {
                    setState(() {
                      _currentAnswer = updated;
                      _answers[_selectedQuestionIndex] = updated;
                    });
                  },
                  onGradeChange: (points, feedback) {
                    debugPrint('Grade: $points, feedback: $feedback');
                  },
                ),
              ),
            ),

            const SizedBox(height: 20),

            // ---- Debug Section ----
            ExpansionTile(
              title: Text(
                'Debug: Current Answer',
                style: theme.textTheme.titleSmall,
              ),
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16,
                  ).copyWith(bottom: 16),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: SelectableText(
                    _formatAnswer(_currentAnswer),
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontFamily: 'monospace',
                    ),
                  ),
                ),
              ],
            ),

            // Usage notes
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.amber.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.amber.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Usage Notes',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ..._usageNotes.map(
                    (note) => Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('  \u2022  ', style: theme.textTheme.bodySmall),
                          Expanded(
                            child: Text(note, style: theme.textTheme.bodySmall),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoChip(String text, Color color, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: theme.textTheme.labelSmall?.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  String _formatAnswer(QuestionAnswer answer) {
    if (answer is MultipleChoiceAnswer) {
      return 'MultipleChoiceAnswer {\n'
          '  questionId: ${answer.questionId}\n'
          '  selectedOptionId: ${answer.selectedOptionId}\n'
          '}';
    }
    if (answer is MatchingAnswer) {
      final matchLines = answer.matches.entries
          .map((e) => '    ${e.key} -> ${e.value}')
          .join('\n');
      return 'MatchingAnswer {\n'
          '  questionId: ${answer.questionId}\n'
          '  matches:\n$matchLines\n'
          '}';
    }
    if (answer is OpenEndedAnswer) {
      return 'OpenEndedAnswer {\n'
          '  questionId: ${answer.questionId}\n'
          '  text: ${answer.text}\n'
          '}';
    }
    if (answer is FillInBlankAnswer) {
      final blankLines = answer.blanks.entries
          .map((e) => '    ${e.key}: ${e.value}')
          .join('\n');
      return 'FillInBlankAnswer {\n'
          '  questionId: ${answer.questionId}\n'
          '  blanks:\n$blankLines\n'
          '}';
    }
    return answer.toString();
  }

  static const _usageNotes = [
    'Editing: Teacher creates/edits questions. All fields are editable.',
    'Viewing: Preview mode showing correct answers. Used in question bank preview.',
    'Doing: Student answering mode. Interactive inputs, no feedback.',
    'Submitted: Read-only view of submitted answers. No correct/incorrect feedback.',
    'After Assessment: Shows correct answers, explanations, and scores.',
    'Grading: Teacher reviews and manually grades answers.',
  ];
}
