import 'package:flutter/material.dart';
import 'package:datn_mobile/features/questions/domain/entity/question_entity.dart';

/// Section for managing fill-in-blank question segments
/// Uses raw text input format: "Text {{answer1 | answer2}} more text"
class FillInBlankSection extends StatefulWidget {
  final List<SegmentData> segments;
  final bool caseSensitive;
  final ValueChanged<List<SegmentData>> onSegmentsChanged;
  final ValueChanged<bool> onCaseSensitiveChanged;

  const FillInBlankSection({
    super.key,
    required this.segments,
    required this.caseSensitive,
    required this.onSegmentsChanged,
    required this.onCaseSensitiveChanged,
  });

  @override
  State<FillInBlankSection> createState() => _FillInBlankSectionState();
}

class _FillInBlankSectionState extends State<FillInBlankSection> {
  late TextEditingController _rawInputController;
  late FocusNode _textFieldFocusNode;
  late List<SegmentData> _parsedSegments;
  String? _parseError;

  @override
  void initState() {
    super.initState();
    // Convert initial segments to raw text format
    _rawInputController = TextEditingController(
      text: _generateRawInput(widget.segments),
    );
    _textFieldFocusNode = FocusNode();
    _parsedSegments = List.from(widget.segments);

    // Listen to text changes
    _rawInputController.addListener(_onRawInputChanged);
  }

  @override
  void dispose() {
    _rawInputController.dispose();
    _textFieldFocusNode.dispose();
    super.dispose();
  }

  void _onRawInputChanged() {
    final rawText = _rawInputController.text;
    try {
      final segments = _parseRawInput(rawText);
      setState(() {
        _parsedSegments = segments;
        _parseError = null;
      });
      widget.onSegmentsChanged(segments);
    } catch (e) {
      setState(() {
        _parseError = e.toString();
      });
    }
  }

  /// Insert {{}} at cursor position and place cursor in the middle
  void _insertBlankAtCursor() {
    final currentText = _rawInputController.text;
    final cursorPosition = _rawInputController.selection.baseOffset;

    // If no selection or invalid position, append at end
    final insertPosition = cursorPosition >= 0
        ? cursorPosition
        : currentText.length;

    // Insert {{}} at cursor position
    final newText =
        '${currentText.substring(0, insertPosition)}{{}}${currentText.substring(insertPosition)}';

    // Update text
    _rawInputController.text = newText;

    // Set cursor position to be between the braces (insertPosition + 2 to be after {{)
    _rawInputController.selection = TextSelection.fromPosition(
      TextPosition(offset: insertPosition + 2),
    );

    // Request focus so user can immediately type
    _textFieldFocusNode.requestFocus();
  }

  /// Parse raw text input into segments
  /// Format: "Text {{answer1 | answer2 | ...}} more text"
  List<SegmentData> _parseRawInput(String input) {
    if (input.trim().isEmpty) {
      return [
        SegmentData(
          type: SegmentType.text,
          content: '',
          acceptableAnswers: null,
        ),
      ];
    }

    final segments = <SegmentData>[];
    final regex = RegExp(r'\{\{(.*?)\}\}');
    final matches = regex.allMatches(input);

    int currentIndex = 0;

    for (final match in matches) {
      // Add text before the blank (if any)
      if (match.start > currentIndex) {
        final textContent = input.substring(currentIndex, match.start);
        if (textContent.isNotEmpty) {
          segments.add(
            SegmentData(
              type: SegmentType.text,
              content: textContent,
              acceptableAnswers: null,
            ),
          );
        }
      }

      // Add the blank segment
      final blankContent = match.group(1) ?? '';
      final answers = blankContent
          .split('|')
          .map((s) => s.trim())
          .where((s) => s.isNotEmpty)
          .toList();

      if (answers.isNotEmpty) {
        segments.add(
          SegmentData(
            type: SegmentType.blank,
            content: answers.first,
            acceptableAnswers: answers,
          ),
        );
      }

      currentIndex = match.end;
    }

    // Add remaining text after last blank (if any)
    if (currentIndex < input.length) {
      final textContent = input.substring(currentIndex);
      if (textContent.isNotEmpty) {
        segments.add(
          SegmentData(
            type: SegmentType.text,
            content: textContent,
            acceptableAnswers: null,
          ),
        );
      }
    }

    // If no segments were created, add an empty text segment
    if (segments.isEmpty) {
      segments.add(
        SegmentData(
          type: SegmentType.text,
          content: input,
          acceptableAnswers: null,
        ),
      );
    }

    return segments;
  }

  /// Generate raw text from segments
  /// Converts segments back to the format: "Text {{answer1 | answer2}} more text"
  String _generateRawInput(List<SegmentData> segments) {
    final buffer = StringBuffer();

    for (final segment in segments) {
      if (segment.type == SegmentType.text) {
        buffer.write(segment.content);
      } else if (segment.type == SegmentType.blank) {
        buffer.write('{{');
        if (segment.acceptableAnswers != null &&
            segment.acceptableAnswers!.isNotEmpty) {
          buffer.write(segment.acceptableAnswers!.join(' | '));
        } else {
          buffer.write(segment.content);
        }
        buffer.write('}}');
      }
    }

    return buffer.toString();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section header
        _buildSectionHeader(
          context,
          'Fill in the Blank Question',
          'Use {{answer}} syntax to create blanks',
        ),
        const SizedBox(height: 16),

        // Format info card
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: colorScheme.primaryContainer.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: colorScheme.primary.withValues(alpha: 0.2),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: colorScheme.primary,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Format Guide',
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _buildFormatExample(
                theme,
                colorScheme,
                'Single answer:',
                'The capital of France is {{Paris}}',
              ),
              const SizedBox(height: 8),
              _buildFormatExample(
                theme,
                colorScheme,
                'Multiple answers:',
                'The color is {{red | blue | green}}',
              ),
              const SizedBox(height: 8),
              Text(
                '• Use {{}} to create a blank\n'
                '• Use | to separate multiple acceptable answers\n'
                '• The first answer will be shown as primary',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurface.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Raw text input with quick insert button
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'Question Text *',
              style: theme.textTheme.labelMedium?.copyWith(
                color: colorScheme.onSurface,
                fontWeight: FontWeight.w500,
              ),
            ),
            FilledButton.tonalIcon(
              onPressed: _insertBlankAtCursor,
              icon: const Icon(Icons.add_circle_outline, size: 18),
              label: const Text('Insert Blank'),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                minimumSize: const Size(0, 36),
                visualDensity: VisualDensity.compact,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _rawInputController,
          focusNode: _textFieldFocusNode,
          maxLines: 5,
          decoration: InputDecoration(
            hintText:
                'Example: The {{quick | fast}} brown fox jumps over the {{lazy}} dog.',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            filled: true,
            fillColor: colorScheme.surfaceContainerLowest,
            errorText: _parseError,
          ),
        ),
        const SizedBox(height: 24),

        // Preview section
        Text(
          'Preview',
          style: theme.textTheme.labelMedium?.copyWith(
            color: colorScheme.onSurface,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        _buildPreview(theme, colorScheme),

        const SizedBox(height: 24),

        // Case sensitive toggle
        SwitchListTile(
          value: widget.caseSensitive,
          onChanged: widget.onCaseSensitiveChanged,
          title: Text(
            'Case Sensitive',
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
          subtitle: Text(
            'Answers must match exact capitalization',
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 4),
        ),

        // Validation warnings
        if (!_hasAtLeastOneBlank())
          Container(
            margin: const EdgeInsets.only(top: 16),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: colorScheme.errorContainer,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: colorScheme.error.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.warning_amber_rounded,
                  color: colorScheme.onErrorContainer,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Please add at least one blank using {{answer}} syntax',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onErrorContainer,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  bool _hasAtLeastOneBlank() {
    return _parsedSegments.any((segment) => segment.type == SegmentType.blank);
  }

  Widget _buildFormatExample(
    ThemeData theme,
    ColorScheme colorScheme,
    String label,
    String example,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 120,
          child: Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurface,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: colorScheme.outline.withValues(alpha: 0.3),
              ),
            ),
            child: Text(
              example,
              style: theme.textTheme.bodySmall?.copyWith(
                fontFamily: 'monospace',
                color: colorScheme.onSurface,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPreview(ThemeData theme, ColorScheme colorScheme) {
    if (_parsedSegments.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: colorScheme.outlineVariant),
        ),
        child: Center(
          child: Text(
            'Preview will appear here',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
              fontStyle: FontStyle.italic,
            ),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Wrap(
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 4,
        runSpacing: 8,
        children: _parsedSegments.map((segment) {
          if (segment.type == SegmentType.text) {
            return Text(
              segment.content,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurface,
              ),
            );
          } else {
            // Blank segment - show as chip
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: colorScheme.primary.withValues(alpha: 0.5),
                  width: 2,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.edit_outlined,
                    size: 16,
                    color: colorScheme.onPrimaryContainer,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    segment.content,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onPrimaryContainer,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (segment.acceptableAnswers != null &&
                      segment.acceptableAnswers!.length > 1) ...[
                    const SizedBox(width: 6),
                    Tooltip(
                      message:
                          'Accepts: ${segment.acceptableAnswers!.join(', ')}',
                      child: Icon(
                        Icons.info_outline,
                        size: 14,
                        color: colorScheme.onPrimaryContainer.withValues(
                          alpha: 0.7,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            );
          }
        }).toList(),
      ),
    );
  }

  Widget _buildSectionHeader(
    BuildContext context,
    String title,
    String subtitle,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: colorScheme.primary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: theme.textTheme.bodySmall?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 12),
        Divider(color: colorScheme.outlineVariant),
      ],
    );
  }
}

/// Data class for fill-in-blank segment
class SegmentData {
  final SegmentType type;
  final String content;
  final List<String>? acceptableAnswers;

  SegmentData({
    required this.type,
    required this.content,
    this.acceptableAnswers,
  });

  /// Convert to JSON for API submission
  Map<String, dynamic> toJson() {
    return {
      'type': type == SegmentType.text ? 'TEXT' : 'BLANK',
      'content': content,
      if (acceptableAnswers != null) 'acceptableAnswers': acceptableAnswers,
    };
  }

  /// Create from JSON
  factory SegmentData.fromJson(Map<String, dynamic> json) {
    return SegmentData(
      type: json['type'] == 'TEXT' ? SegmentType.text : SegmentType.blank,
      content: json['content'] as String,
      acceptableAnswers: json['acceptableAnswers'] != null
          ? List<String>.from(json['acceptableAnswers'])
          : null,
    );
  }
}
