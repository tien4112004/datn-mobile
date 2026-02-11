import 'package:flutter/material.dart';

/// Assignment settings section for exercise posts
class AssignmentSettingsSection extends StatelessWidget {
  final bool isDisabled;
  final int? maxSubmissions;
  final double? passingScore;
  final bool allowRetake;
  final bool shuffleQuestions;
  final bool showCorrectAnswers;
  final bool showScoreImmediately;
  final ValueChanged<int?>? onMaxSubmissionsChanged;
  final ValueChanged<double?>? onPassingScoreChanged;
  final ValueChanged<bool>? onAllowRetakeChanged;
  final ValueChanged<bool>? onShuffleQuestionsChanged;
  final ValueChanged<bool>? onShowCorrectAnswersChanged;
  final ValueChanged<bool>? onShowScoreImmediatelyChanged;

  const AssignmentSettingsSection({
    super.key,
    required this.isDisabled,
    this.maxSubmissions,
    this.passingScore,
    required this.allowRetake,
    required this.shuffleQuestions,
    required this.showCorrectAnswers,
    required this.showScoreImmediately,
    this.onMaxSubmissionsChanged,
    this.onPassingScoreChanged,
    this.onAllowRetakeChanged,
    this.onShuffleQuestionsChanged,
    this.onShowCorrectAnswersChanged,
    this.onShowScoreImmediatelyChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

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
                'Assignment Settings',
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
                      'Max Submissions',
                      style: theme.textTheme.bodyMedium,
                    ),
                  ),
                  SizedBox(
                    width: 100,
                    child: TextField(
                      enabled: !isDisabled,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        hintText: 'Unlimited',
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
                      'Passing Score (%)',
                      style: theme.textTheme.bodyMedium,
                    ),
                  ),
                  SizedBox(
                    width: 100,
                    child: TextField(
                      enabled: !isDisabled,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        hintText: '0-100',
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
                title: Text('Allow Retake', style: theme.textTheme.bodyMedium),
                subtitle: Text(
                  'Students can retake the assignment',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ),

              // Shuffle Questions
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                value: shuffleQuestions,
                onChanged: isDisabled ? null : onShuffleQuestionsChanged,
                title: Text(
                  'Shuffle Questions',
                  style: theme.textTheme.bodyMedium,
                ),
                subtitle: Text(
                  'Randomize question order',
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
                  'Show Correct Answers',
                  style: theme.textTheme.bodyMedium,
                ),
                subtitle: Text(
                  'Display correct answers after submission',
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
                  'Show Score Immediately',
                  style: theme.textTheme.bodyMedium,
                ),
                subtitle: Text(
                  'Display score right after submission',
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
