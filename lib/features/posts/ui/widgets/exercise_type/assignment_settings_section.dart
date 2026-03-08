import 'package:AIPrimary/shared/pods/translation_pod.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Assignment settings section for exercise posts
class AssignmentSettingsSection extends ConsumerStatefulWidget {
  final bool isDisabled;
  final String? assignmentTitle;
  final int? maxSubmissions;
  final double? passingScore;
  final bool allowRetake;
  final bool showCorrectAnswers;
  final bool showScoreImmediately;
  final ValueChanged<String>? onAssignmentTitleChanged;
  final ValueChanged<int?>? onMaxSubmissionsChanged;
  final ValueChanged<double?>? onPassingScoreChanged;
  final ValueChanged<bool>? onAllowRetakeChanged;
  final ValueChanged<bool>? onShowCorrectAnswersChanged;
  final ValueChanged<bool>? onShowScoreImmediatelyChanged;

  const AssignmentSettingsSection({
    super.key,
    required this.isDisabled,
    this.assignmentTitle,
    this.maxSubmissions,
    this.passingScore,
    required this.allowRetake,
    required this.showCorrectAnswers,
    required this.showScoreImmediately,
    this.onAssignmentTitleChanged,
    this.onMaxSubmissionsChanged,
    this.onPassingScoreChanged,
    this.onAllowRetakeChanged,
    this.onShowCorrectAnswersChanged,
    this.onShowScoreImmediatelyChanged,
  });

  @override
  ConsumerState<AssignmentSettingsSection> createState() =>
      _AssignmentSettingsSectionState();
}

class _AssignmentSettingsSectionState
    extends ConsumerState<AssignmentSettingsSection> {
  late final TextEditingController _titleController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(
      text: widget.assignmentTitle ?? '',
    );
  }

  @override
  void didUpdateWidget(AssignmentSettingsSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Sync controller when assignment changes externally (e.g., re-selection)
    if (oldWidget.assignmentTitle != widget.assignmentTitle &&
        _titleController.text != (widget.assignmentTitle ?? '')) {
      _titleController.text = widget.assignmentTitle ?? '';
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final t = ref.watch(translationsPod);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Material(
        color: colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                t.classes.assignmentSettings.title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),

              // Assignment Title
              TextField(
                controller: _titleController,
                enabled: !widget.isDisabled,
                decoration: InputDecoration(
                  labelText: t.classes.assignmentSelection.assignmentTitle,
                  hintText: t.classes.assignmentSelection.assignmentTitle,
                  filled: true,
                  fillColor: colorScheme.surface,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                ),
                onChanged: widget.onAssignmentTitleChanged,
              ),

              const SizedBox(height: 12),

              // Max Submissions
              Row(
                children: [
                  Expanded(
                    child: Text(
                      t.classes.assignmentSettings.maxSubmissions,
                      style: theme.textTheme.bodyMedium,
                    ),
                  ),
                  SizedBox(
                    width: 100,
                    child: TextField(
                      enabled: !widget.isDisabled,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        hintText:
                            t.classes.assignmentSettings.maxSubmissionsHint,
                        filled: true,
                        fillColor: colorScheme.surface,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                      ),
                      onChanged: (value) {
                        final parsed = int.tryParse(value);
                        widget.onMaxSubmissionsChanged?.call(parsed);
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Passing Score
              Row(
                children: [
                  Expanded(
                    child: Text(
                      t.classes.assignmentSettings.passingScore,
                      style: theme.textTheme.bodyMedium,
                    ),
                  ),
                  SizedBox(
                    width: 100,
                    child: TextField(
                      enabled: !widget.isDisabled,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        hintText: t.classes.assignmentSettings.passingScoreHint,
                        filled: true,
                        fillColor: colorScheme.surface,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                      ),
                      onChanged: (value) {
                        final parsed = double.tryParse(value);
                        widget.onPassingScoreChanged?.call(parsed);
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),
              Divider(color: colorScheme.outlineVariant),
              const SizedBox(height: 16),

              // Allow Retake
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                value: widget.allowRetake,
                onChanged: widget.isDisabled
                    ? null
                    : widget.onAllowRetakeChanged,
                title: Text(
                  t.classes.assignmentSettings.allowRetake,
                  style: theme.textTheme.bodyMedium,
                ),
                subtitle: Text(
                  t.classes.assignmentSettings.allowRetakeDesc,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ),

              // Show Correct Answers
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                value: widget.showCorrectAnswers,
                onChanged: widget.isDisabled
                    ? null
                    : widget.onShowCorrectAnswersChanged,
                title: Text(
                  t.classes.assignmentSettings.showCorrectAnswers,
                  style: theme.textTheme.bodyMedium,
                ),
                subtitle: Text(
                  t.classes.assignmentSettings.showCorrectAnswersDesc,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ),

              // Show Score Immediately
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                value: widget.showScoreImmediately,
                onChanged: widget.isDisabled
                    ? null
                    : widget.onShowScoreImmediatelyChanged,
                title: Text(
                  t.classes.assignmentSettings.showScoreImmediately,
                  style: theme.textTheme.bodyMedium,
                ),
                subtitle: Text(
                  t.classes.assignmentSettings.showScoreImmediatelyDesc,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
