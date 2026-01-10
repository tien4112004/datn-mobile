import 'package:flutter/material.dart';
import 'package:datn_mobile/features/questions/ui/widgets/modify/matching_pair_card.dart';

/// Section for managing matching question pairs
class MatchingSection extends StatefulWidget {
  final List<MatchingPairData> pairs;
  final bool shufflePairs;
  final ValueChanged<List<MatchingPairData>> onPairsChanged;
  final ValueChanged<bool> onShuffleChanged;

  const MatchingSection({
    super.key,
    required this.pairs,
    required this.shufflePairs,
    required this.onPairsChanged,
    required this.onShuffleChanged,
  });

  @override
  State<MatchingSection> createState() => _MatchingSectionState();
}

class _MatchingSectionState extends State<MatchingSection> {
  late List<MatchingPairData> _pairs;

  @override
  void initState() {
    super.initState();
    _pairs = List.from(widget.pairs);
  }

  void _addPair() {
    setState(() {
      _pairs.add(
        MatchingPairData(
          leftText: '',
          leftImageUrl: null,
          rightText: '',
          rightImageUrl: null,
        ),
      );
    });
    widget.onPairsChanged(_pairs);
  }

  void _removePair(int index) {
    if (_pairs.length <= 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('At least 2 pairs are required'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() {
      _pairs.removeAt(index);
    });
    widget.onPairsChanged(_pairs);
  }

  void _updatePair(
    int index, {
    String? leftText,
    String? leftImageUrl,
    String? rightText,
    String? rightImageUrl,
  }) {
    setState(() {
      _pairs[index] = MatchingPairData(
        leftText: leftText ?? _pairs[index].leftText,
        leftImageUrl: leftImageUrl ?? _pairs[index].leftImageUrl,
        rightText: rightText ?? _pairs[index].rightText,
        rightImageUrl: rightImageUrl ?? _pairs[index].rightImageUrl,
      );
    });
    widget.onPairsChanged(_pairs);
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
          'Matching Pairs',
          'Create pairs to match (minimum 2 required)',
        ),
        const SizedBox(height: 16),

        // Pairs list
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _pairs.length,
          itemBuilder: (context, index) {
            return MatchingPairCard(
              key: ValueKey('pair_$index'),
              index: index,
              leftText: _pairs[index].leftText,
              leftImageUrl: _pairs[index].leftImageUrl,
              rightText: _pairs[index].rightText,
              rightImageUrl: _pairs[index].rightImageUrl,
              canRemove: _pairs.length > 2,
              onRemove: () => _removePair(index),
              onLeftTextChanged: (value) => _updatePair(index, leftText: value),
              onLeftImageChanged: (value) => _updatePair(
                index,
                leftImageUrl: value?.isEmpty == true ? null : value,
              ),
              onRightTextChanged: (value) =>
                  _updatePair(index, rightText: value),
              onRightImageChanged: (value) => _updatePair(
                index,
                rightImageUrl: value?.isEmpty == true ? null : value,
              ),
            );
          },
        ),

        // Add pair button
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: _addPair,
            icon: const Icon(Icons.add_circle_outline),
            label: const Text('Add Pair'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Shuffle pairs toggle
        SwitchListTile(
          value: widget.shufflePairs,
          onChanged: widget.onShuffleChanged,
          title: Text(
            'Shuffle Pairs',
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
          subtitle: Text(
            'Randomize pair order when displayed to students',
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 4),
        ),
      ],
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

/// Data class for matching pair
class MatchingPairData {
  final String leftText;
  final String? leftImageUrl;
  final String rightText;
  final String? rightImageUrl;

  MatchingPairData({
    required this.leftText,
    this.leftImageUrl,
    required this.rightText,
    this.rightImageUrl,
  });
}
