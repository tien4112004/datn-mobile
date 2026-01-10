import 'package:auto_route/auto_route.dart';
import 'package:datn_mobile/core/router/router.gr.dart';
import 'package:datn_mobile/features/questions/domain/entity/question_entity.dart';
import 'package:flutter/material.dart';
import 'package:datn_mobile/features/questions/domain/entity/question_enums.dart';
import 'package:datn_mobile/features/questions/ui/pages/modify/question_basic_info_section.dart';
import 'package:datn_mobile/features/questions/ui/pages/modify/multiple_choice_section.dart';
import 'package:datn_mobile/features/questions/ui/pages/modify/matching_section.dart';
import 'package:datn_mobile/features/questions/ui/pages/modify/open_ended_section.dart';
import 'package:datn_mobile/features/questions/ui/pages/modify/fill_in_blank_section.dart';
import 'package:datn_mobile/shared/widgets/custom_app_bar.dart';

/// Page for creating or editing a question
@RoutePage()
class QuestionModifyPage extends StatefulWidget {
  /// Question ID if editing, null if creating new
  final String? questionId;

  const QuestionModifyPage({super.key, this.questionId});

  @override
  State<QuestionModifyPage> createState() => _QuestionModifyPageState();
}

class _QuestionModifyPageState extends State<QuestionModifyPage> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _hasUnsavedChanges = false;

  // Basic info controllers
  final _titleController = TextEditingController();
  final _pointsController = TextEditingController();
  final _explanationController = TextEditingController();

  // Basic info state
  QuestionType _selectedType = QuestionType.multipleChoice;
  Difficulty _selectedDifficulty = Difficulty.knowledge;
  String? _titleImageUrl;

  // Multiple choice state
  List<MultipleChoiceOptionData> _mcOptions = [
    MultipleChoiceOptionData(text: '', imageUrl: null, isCorrect: false),
    MultipleChoiceOptionData(text: '', imageUrl: null, isCorrect: false),
  ];
  bool _shuffleOptions = false;

  // Matching state
  List<MatchingPairData> _matchingPairs = [
    MatchingPairData(
      leftText: '',
      leftImageUrl: null,
      rightText: '',
      rightImageUrl: null,
    ),
    MatchingPairData(
      leftText: '',
      leftImageUrl: null,
      rightText: '',
      rightImageUrl: null,
    ),
  ];
  bool _shufflePairs = false;

  // Open-ended state
  final _expectedAnswerController = TextEditingController();
  final _maxLengthController = TextEditingController();

  // Fill-in-blank state
  List<SegmentData> _segments = [
    SegmentData(type: SegmentType.text, content: '', acceptableAnswers: null),
  ];
  bool _caseSensitive = false;

  bool get _isEditing => widget.questionId != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      _loadQuestion();
    }
    _addChangeListeners();
  }

  void _addChangeListeners() {
    _titleController.addListener(_markUnsaved);
    _pointsController.addListener(_markUnsaved);
    _explanationController.addListener(_markUnsaved);
    _expectedAnswerController.addListener(_markUnsaved);
    _maxLengthController.addListener(_markUnsaved);
  }

  void _markUnsaved() {
    if (!_hasUnsavedChanges) {
      setState(() => _hasUnsavedChanges = true);
    }
  }

  Future<void> _loadQuestion() async {
    // TODO: Load question data from repository
    setState(() => _isLoading = true);
    // Simulate loading
    await Future.delayed(const Duration(seconds: 1));
    setState(() => _isLoading = false);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _pointsController.dispose();
    _explanationController.dispose();
    _expectedAnswerController.dispose();
    _maxLengthController.dispose();
    super.dispose();
  }

  Future<bool> _onWillPop() async {
    if (!_hasUnsavedChanges) return true;

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Discard changes?'),
        content: const Text(
          'You have unsaved changes. Are you sure you want to leave?',
        ),
        actions: [
          TextButton(
            onPressed: () => context.router.maybePop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => context.router.replace(const QuestionBankRoute()),
            child: const Text('Discard'),
          ),
        ],
      ),
    );

    return result ?? false;
  }

  void _handleSave() async {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fix the errors in the form'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    // Additional validation based on question type
    if (!_validateTypeSpecificData()) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      // TODO: Save question to repository
      await Future.delayed(const Duration(seconds: 1));

      if (!mounted) return;

      setState(() {
        _hasUnsavedChanges = false;
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _isEditing
                ? 'Question updated successfully'
                : 'Question created successfully',
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );

      // Navigate back
      context.router.maybePop();
    } catch (e) {
      if (!mounted) return;

      setState(() => _isLoading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error saving question: $e'),
          backgroundColor: Theme.of(context).colorScheme.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  bool _validateTypeSpecificData() {
    switch (_selectedType) {
      case QuestionType.multipleChoice:
        if (!_mcOptions.any((opt) => opt.isCorrect)) {
          _showError('Please mark at least one option as correct');
          return false;
        }
        if (_mcOptions.any((opt) => opt.text.trim().isEmpty)) {
          _showError('All options must have text');
          return false;
        }
        break;

      case QuestionType.matching:
        if (_matchingPairs.any(
          (pair) =>
              pair.leftText.trim().isEmpty || pair.rightText.trim().isEmpty,
        )) {
          _showError('All matching pairs must have both left and right text');
          return false;
        }
        break;

      case QuestionType.fillInBlank:
        if (!_segments.any((seg) => seg.type == SegmentType.blank)) {
          _showError('Please add at least one blank segment');
          return false;
        }
        if (_segments.any((seg) => seg.content.trim().isEmpty)) {
          _showError('All segments must have content');
          return false;
        }
        break;

      case QuestionType.openEnded:
        // Open-ended has no specific validation requirements
        break;
    }

    return true;
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).colorScheme.error,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return PopScope(
      canPop: !_hasUnsavedChanges,
      onPopInvokedWithResult: (didPop, result) async {
        if (!didPop) {
          final shouldPop = await _onWillPop();
          if (shouldPop && context.mounted) {
            context.router.maybePop();
          }
        }
      },
      child: Scaffold(
        backgroundColor: colorScheme.surface,
        appBar: CustomAppBar(
          title: _isEditing ? 'Edit Question' : 'Create Question',
          actions: [
            if (_isLoading)
              const Padding(
                padding: EdgeInsets.all(16),
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              )
            else
              IconButton(
                icon: const Icon(Icons.check_rounded),
                onPressed: _handleSave,
                tooltip: 'Save',
              ),
          ],
        ),
        body: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Basic information section
              QuestionBasicInfoSection(
                titleController: _titleController,
                selectedType: _selectedType,
                selectedDifficulty: _selectedDifficulty,
                pointsController: _pointsController,
                titleImageUrl: _titleImageUrl,
                explanationController: _explanationController,
                onTypeChanged: (type) {
                  setState(() {
                    _selectedType = type;
                    _markUnsaved();
                  });
                },
                onDifficultyChanged: (difficulty) {
                  setState(() {
                    _selectedDifficulty = difficulty;
                    _markUnsaved();
                  });
                },
                onTitleImageChanged: (url) {
                  setState(() {
                    _titleImageUrl = url;
                    _markUnsaved();
                  });
                },
              ),
              const SizedBox(height: 32),

              // Type-specific section
              _buildTypeSpecificSection(),

              const SizedBox(height: 32),

              // Bottom action buttons
              _buildActionButtons(),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTypeSpecificSection() {
    switch (_selectedType) {
      case QuestionType.multipleChoice:
        return MultipleChoiceSection(
          options: _mcOptions,
          shuffleOptions: _shuffleOptions,
          onOptionsChanged: (options) {
            setState(() {
              _mcOptions = options;
              _markUnsaved();
            });
          },
          onShuffleChanged: (value) {
            setState(() {
              _shuffleOptions = value;
              _markUnsaved();
            });
          },
        );

      case QuestionType.matching:
        return MatchingSection(
          pairs: _matchingPairs,
          shufflePairs: _shufflePairs,
          onPairsChanged: (pairs) {
            setState(() {
              _matchingPairs = pairs;
              _markUnsaved();
            });
          },
          onShuffleChanged: (value) {
            setState(() {
              _shufflePairs = value;
              _markUnsaved();
            });
          },
        );

      case QuestionType.openEnded:
        return OpenEndedSection(
          expectedAnswerController: _expectedAnswerController,
          maxLengthController: _maxLengthController,
        );

      case QuestionType.fillInBlank:
        return FillInBlankSection(
          segments: _segments,
          caseSensitive: _caseSensitive,
          onSegmentsChanged: (segments) {
            setState(() {
              _segments = segments;
              _markUnsaved();
            });
          },
          onCaseSensitiveChanged: (value) {
            setState(() {
              _caseSensitive = value;
              _markUnsaved();
            });
          },
        );
    }
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: _isLoading
                ? null
                : () async {
                    final shouldPop = await _onWillPop();
                    if (shouldPop && mounted) {
                      context.router.maybePop();
                    }
                  },
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Cancel'),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: FilledButton(
            onPressed: _isLoading ? null : _handleSave,
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(_isEditing ? 'Update' : 'Create'),
          ),
        ),
      ],
    );
  }
}
