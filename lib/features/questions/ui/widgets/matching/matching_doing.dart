import 'package:AIPrimary/i18n/strings.g.dart';
import 'package:AIPrimary/shared/pods/translation_pod.dart';
import 'package:AIPrimary/shared/widgets/flex_dropdown_field.dart';
import 'package:flutter/material.dart';
import 'package:AIPrimary/features/questions/domain/entity/question_entity.dart';
import 'package:AIPrimary/features/questions/ui/widgets/question_card_wrapper.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '_matching_content_widget.dart';

/// Matching Question in Doing Mode
class MatchingDoing extends ConsumerStatefulWidget {
  final MatchingQuestion question;
  final Map<String, String>? answers; // pairId -> selectedRightId
  final Function(Map<String, String>)? onAnswersChanged;

  const MatchingDoing({
    super.key,
    required this.question,
    this.answers,
    this.onAnswersChanged,
  });

  @override
  ConsumerState<MatchingDoing> createState() => _MatchingDoingState();
}

class _MatchingDoingState extends ConsumerState<MatchingDoing> {
  late Map<String, String?> _selectedAnswers;
  late List<MatchingPair> _shuffledRightPairs;

  @override
  void initState() {
    super.initState();
    _selectedAnswers = Map.from(widget.answers ?? {});
    // Store shuffled pairs instead of just text for image support
    _shuffledRightPairs = List.from(widget.question.data.pairs)..shuffle();
  }

  void _selectMatch(String pairId, String? rightPairId) {
    setState(() {
      _selectedAnswers[pairId] = rightPairId;
    });
    widget.onAnswersChanged?.call(
      Map.from(
        _selectedAnswers,
      ).map((key, value) => MapEntry(key, value ?? '')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = ref.watch(translationsPod);
    final theme = Theme.of(context);

    return QuestionCardWrapper(
      title: widget.question.title,
      titleImageUrl: widget.question.titleImageUrl,
      difficulty: widget.question.difficulty,
      type: widget.question.type,
      showHeader: true,
      showBadges: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${t.questionBank.matching.subtitle}:',
            style: theme.textTheme.labelSmall?.copyWith(
              color: Colors.orange,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          ...widget.question.data.pairs.map((pair) {
            return _buildMatchingPair(pair, theme, t);
          }),
        ],
      ),
    );
  }

  Widget _buildMatchingPair(
    MatchingPair pair,
    ThemeData theme,
    Translations t,
  ) {
    final selectedRightPairId = _selectedAnswers[pair.id];

    // Check if any pair has images
    final hasAnyImages = _shuffledRightPairs.any(
      (p) => (p.rightImageUrl != null && p.rightImageUrl!.isNotEmpty),
    );

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left side (question)
          Text(
            '${t.questionBank.matching.leftSide}:',
            style: theme.textTheme.labelSmall?.copyWith(
              color: Colors.orange,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          MatchingContentWidget(
            text: pair.left,
            imageUrl: pair.leftImageUrl,
            backgroundColor: Colors.orange[50],
            borderColor: Colors.orange[200],
            borderWidth: 2,
          ),
          const SizedBox(height: 12),
          // Right side selection
          Text(
            '${t.questionBank.matching.rightSide}:',
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          // Use grid for images, dropdown for text
          hasAnyImages
              ? _buildImageSelectionGrid(pair, selectedRightPairId, theme, t)
              : _buildTextDropdown(pair, selectedRightPairId, theme, t),
        ],
      ),
    );
  }

  /// Build dropdown for text-only matching
  Widget _buildTextDropdown(
    MatchingPair pair,
    String? selectedRightPairId,
    ThemeData theme,
    Translations t,
  ) {
    final placeholder = t.questionBank.matching.enterRightText;
    final selectedPair = selectedRightPairId != null
        ? _shuffledRightPairs.firstWhere((p) => p.id == selectedRightPairId)
        : null;
    final currentValue = selectedPair?.right ?? placeholder;
    final dropdownItems = [
      placeholder,
      ..._shuffledRightPairs.map((p) => p.right ?? ""),
    ];

    return FlexDropdownField<String>(
      value: currentValue,
      items: dropdownItems,
      onChanged: (value) {
        if (value != placeholder) {
          final selectedPair = _shuffledRightPairs.firstWhere(
            (p) => p.right == value,
          );
          _selectMatch(pair.id, selectedPair.id);
        } else {
          _selectMatch(pair.id, null);
        }
      },
    );
  }

  /// Build grid selection for image-based matching
  Widget _buildImageSelectionGrid(
    MatchingPair pair,
    String? selectedRightPairId,
    ThemeData theme,
    Translations t,
  ) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: _shuffledRightPairs.map((rightPair) {
        final isSelected = selectedRightPairId == rightPair.id;
        return InkWell(
          onTap: () {
            _selectMatch(pair.id, isSelected ? null : rightPair.id);
          },
          borderRadius: BorderRadius.circular(12),
          child: Container(
            width: (MediaQuery.of(context).size.width - 80) / 2,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected ? Colors.orange : theme.colorScheme.outline,
                width: isSelected ? 3 : 1,
              ),
              color: isSelected
                  ? const Color.fromARGB(
                      255,
                      255,
                      197,
                      107,
                    ).withValues(alpha: 0.1)
                  : theme.colorScheme.surface,
            ),
            child: Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.all(0),
                  child: MatchingContentWidget(
                    text: rightPair.right,
                    imageUrl: rightPair.rightImageUrl,
                    isCompact: true,
                  ),
                ),
                if (isSelected)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Colors.orange,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}
