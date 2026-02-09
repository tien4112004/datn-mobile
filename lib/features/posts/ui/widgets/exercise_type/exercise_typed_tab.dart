import 'package:AIPrimary/i18n/strings.g.dart';
import 'package:AIPrimary/features/posts/ui/widgets/shared/post_editor_section.dart';
import 'package:AIPrimary/features/posts/ui/widgets/shared/post_actions_section.dart';
import 'package:AIPrimary/features/posts/ui/widgets/exercise_type/due_date_section.dart';
import 'package:AIPrimary/features/posts/ui/widgets/exercise_type/assignment_selection_section.dart';
import 'package:AIPrimary/features/posts/ui/widgets/exercise_type/assignment_settings_section.dart';
import 'package:AIPrimary/features/classes/domain/entity/post_type.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;

/// Exercise type post tab widget combining all exercise-specific sections
class ExerciseTypedTab extends StatelessWidget {
  final quill.QuillController quillController;
  final FocusNode editorFocusNode;
  final bool isSubmitting;
  final DateTime? dueDate;
  final String? selectedAssignmentId;
  final int? maxSubmissions;
  final double? passingScore;
  final bool allowRetake;
  final bool shuffleQuestions;
  final bool showCorrectAnswers;
  final bool showScoreImmediately;
  final int linkedResourcesCount;
  final VoidCallback onPickDueDate;
  final VoidCallback onPickAssignment;
  final VoidCallback onPickLinkedResource;
  final ValueChanged<int?>? onMaxSubmissionsChanged;
  final ValueChanged<double?>? onPassingScoreChanged;
  final ValueChanged<bool>? onAllowRetakeChanged;
  final ValueChanged<bool>? onShuffleQuestionsChanged;
  final ValueChanged<bool>? onShowCorrectAnswersChanged;
  final ValueChanged<bool>? onShowScoreImmediatelyChanged;
  final Translations translations;

  const ExerciseTypedTab({
    super.key,
    required this.quillController,
    required this.editorFocusNode,
    required this.isSubmitting,
    required this.dueDate,
    required this.selectedAssignmentId,
    required this.maxSubmissions,
    required this.passingScore,
    required this.allowRetake,
    required this.shuffleQuestions,
    required this.showCorrectAnswers,
    required this.showScoreImmediately,
    required this.linkedResourcesCount,
    required this.onPickDueDate,
    required this.onPickAssignment,
    required this.onPickLinkedResource,
    this.onMaxSubmissionsChanged,
    this.onPassingScoreChanged,
    this.onAllowRetakeChanged,
    this.onShuffleQuestionsChanged,
    this.onShowCorrectAnswersChanged,
    this.onShowScoreImmediatelyChanged,
    required this.translations,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Due Date Section
        DueDateSection(
          dueDate: dueDate,
          isDisabled: isSubmitting,
          onPickDueDate: onPickDueDate,
          translations: translations,
        ),
        const SizedBox(height: 16),

        // Assignment Selection Section
        AssignmentSelectionSection(
          assignmentId: selectedAssignmentId,
          isDisabled: isSubmitting,
          onPickAssignment: onPickAssignment,
        ),
        const SizedBox(height: 16),

        // Assignment Settings Section (only show when assignment selected)
        if (selectedAssignmentId != null) ...[
          AssignmentSettingsSection(
            isDisabled: isSubmitting,
            maxSubmissions: maxSubmissions,
            passingScore: passingScore,
            allowRetake: allowRetake,
            shuffleQuestions: shuffleQuestions,
            showCorrectAnswers: showCorrectAnswers,
            showScoreImmediately: showScoreImmediately,
            onMaxSubmissionsChanged: onMaxSubmissionsChanged,
            onPassingScoreChanged: onPassingScoreChanged,
            onAllowRetakeChanged: onAllowRetakeChanged,
            onShuffleQuestionsChanged: onShuffleQuestionsChanged,
            onShowCorrectAnswersChanged: onShowCorrectAnswersChanged,
            onShowScoreImmediatelyChanged: onShowScoreImmediatelyChanged,
          ),
          const SizedBox(height: 16),
        ],

        // Link Resource button (assignments)
        PostActionsSection(
          selectedType: PostType.exercise,
          attachmentsCount: 0,
          linkedResourcesCount: linkedResourcesCount,
          isLoading: isSubmitting,
          isUploading: false,
          onPickAttachment: () {}, // Not used for exercise type
          onPickLinkedResource: onPickLinkedResource,
        ),
        const SizedBox(height: 16),

        // Rich Text Editor
        PostEditorSection(
          controller: quillController,
          isLoading: isSubmitting,
          focusNode: editorFocusNode,
        ),
      ],
    );
  }
}
