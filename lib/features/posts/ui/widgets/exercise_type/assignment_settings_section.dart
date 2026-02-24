import 'package:AIPrimary/shared/pods/translation_pod.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Assignment settings section for exercise posts
class AssignmentSettingsSection extends ConsumerWidget {
  final bool isDisabled;
  final int? maxSubmissions;
  final double? passingScore;
  final bool allowRetake;
  final bool showCorrectAnswers;
  final bool showScoreImmediately;
  final ValueChanged<int?>? onMaxSubmissionsChanged;
  final ValueChanged<double?>? onPassingScoreChanged;
  final ValueChanged<bool>? onAllowRetakeChanged;
  final ValueChanged<bool>? onShowCorrectAnswersChanged;
  final ValueChanged<bool>? onShowScoreImmediatelyChanged;

  const AssignmentSettingsSection({
    super.key,
    required this.isDisabled,
    this.maxSubmissions,
    this.passingScore,
    required this.allowRetake,
    required this.showCorrectAnswers,
    required this.showScoreImmediately,
    this.onMaxSubmissionsChanged,
    this.onPassingScoreChanged,
    this.onAllowRetakeChanged,
    this.onShowCorrectAnswersChanged,
    this.onShowScoreImmediatelyChanged,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
                      enabled: !isDisabled,
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
                        onMaxSubmissionsChanged?.call(parsed);
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
                      enabled: !isDisabled,
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
                        onPassingScoreChanged?.call(parsed);
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
                value: allowRetake,
                onChanged: isDisabled ? null : onAllowRetakeChanged,
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
                value: showCorrectAnswers,
                onChanged: isDisabled ? null : onShowCorrectAnswersChanged,
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
                value: showScoreImmediately,
                onChanged: isDisabled ? null : onShowScoreImmediatelyChanged,
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
