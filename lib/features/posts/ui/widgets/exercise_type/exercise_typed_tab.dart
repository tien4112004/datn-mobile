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
  final DateTime? availableFrom;
  final DateTime? dueDate;
  final DateTime? availableUntil;
  final String? selectedAssignmentId;
  final int? maxSubmissions;
  final double? passingScore;
  final bool allowRetake;
  final bool showCorrectAnswers;
  final bool showScoreImmediately;
  final int linkedResourcesCount;
  final VoidCallback onPickAvailableFrom;
  final VoidCallback onPickDueDate;
  final VoidCallback onPickAvailableUntil;
  final VoidCallback onPickAssignment;
  final VoidCallback onPickLinkedResource;
  final ValueChanged<int?>? onMaxSubmissionsChanged;
  final ValueChanged<double?>? onPassingScoreChanged;
  final ValueChanged<bool>? onAllowRetakeChanged;
  final ValueChanged<bool>? onShowCorrectAnswersChanged;
  final ValueChanged<bool>? onShowScoreImmediatelyChanged;
  final Translations translations;

  const ExerciseTypedTab({
    super.key,
    required this.quillController,
    required this.editorFocusNode,
    required this.isSubmitting,
    required this.availableFrom,
    required this.dueDate,
    required this.availableUntil,
    required this.selectedAssignmentId,
    required this.maxSubmissions,
    required this.passingScore,
    required this.allowRetake,
    required this.showCorrectAnswers,
    required this.showScoreImmediately,
    required this.linkedResourcesCount,
    required this.onPickAvailableFrom,
    required this.onPickDueDate,
    required this.onPickAvailableUntil,
    required this.onPickAssignment,
    required this.onPickLinkedResource,
    this.onMaxSubmissionsChanged,
    this.onPassingScoreChanged,
    this.onAllowRetakeChanged,
    this.onShowCorrectAnswersChanged,
    this.onShowScoreImmediatelyChanged,
    required this.translations,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Availability Window Section (availableFrom + dueDate + availableUntil)
        DueDateSection(
          availableFrom: availableFrom,
          dueDate: dueDate,
          availableUntil: availableUntil,
          isDisabled: isSubmitting,
          onPickAvailableFrom: onPickAvailableFrom,
          onPickDueDate: onPickDueDate,
          onPickAvailableUntil: onPickAvailableUntil,
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
            showCorrectAnswers: showCorrectAnswers,
            showScoreImmediately: showScoreImmediately,
            onMaxSubmissionsChanged: onMaxSubmissionsChanged,
            onPassingScoreChanged: onPassingScoreChanged,
            onAllowRetakeChanged: onAllowRetakeChanged,
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
