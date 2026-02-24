import 'package:AIPrimary/shared/models/cms_enums.dart';
import 'package:AIPrimary/shared/pods/translation_pod.dart';
import 'package:AIPrimary/shared/utils/enum_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Radio-button list for selecting the missing question strategy.
class MissingStrategySelector extends ConsumerWidget {
  final MissingQuestionStrategy selected;
  final ValueChanged<MissingQuestionStrategy> onChanged;

  const MissingStrategySelector({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(translationsPod);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: MissingQuestionStrategy.values.map((strategy) {
        return RadioListTile<MissingQuestionStrategy>(
          value: strategy,
          groupValue: selected,
          title: Text(strategy.localizedName(t)),
          onChanged: (v) {
            if (v != null) onChanged(v);
          },
        );
      }).toList(),
    );
  }
}
