import 'dart:core';

import 'package:AIPrimary/features/generate/states/controller_provider.dart';
import 'package:AIPrimary/features/generate/ui/widgets/options/general_picker_options.dart';
import 'package:AIPrimary/features/generate/ui/widgets/shared/setting_item.dart';
import 'package:AIPrimary/i18n/strings.g.dart';
import 'package:AIPrimary/shared/widgets/picker_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MindmapWidgetOptions {
  static List<int> availableMaxDepths = [1, 2, 3, 4, 5];
  static List<int> availableMaxBranches = [2, 3, 4, 5, 6, 7, 8, 9, 10];

  static Widget buildDepthLevelSetting(Translations t) {
    return Consumer(
      builder: (context, ref, _) {
        final formState = ref.watch(mindmapFormControllerProvider);
        final formController = ref.read(mindmapFormControllerProvider.notifier);

        return SettingItem(
          label: t.generate.mindmapGenerate.depthLevel,
          child: StatefulBuilder(
            builder: (context, setSheetState) {
              return PickerButton(
                label: '${formState.maxDepth}',
                onTap: () => GeneralPickerOptions.showEnumPicker<int>(
                  context: context,
                  title: t.generate.mindmapGenerate.depthLevel,
                  values: availableMaxDepths,
                  labelOf: (v) => '$v',
                  isSelected: (v) => v == formState.maxDepth,
                  onSelected: (v) {
                    formController.updateMaxDepth(v);
                    setSheetState(() {});
                  },
                ),
              );
            },
          ),
        );
      },
    );
  }

  static Widget buildMaxBranchesSetting(Translations t) {
    return Consumer(
      builder: (context, ref, _) {
        final formState = ref.watch(mindmapFormControllerProvider);
        final formController = ref.read(mindmapFormControllerProvider.notifier);

        return SettingItem(
          label: t.generate.mindmapGenerate.selectMaxBranches,
          child: StatefulBuilder(
            builder: (context, setSheetState) {
              return PickerButton(
                label: '${formState.maxBranchesPerNode}',
                onTap: () => GeneralPickerOptions.showEnumPicker<int>(
                  context: context,
                  title: t.generate.mindmapGenerate.selectMaxBranches,
                  values: availableMaxBranches,
                  labelOf: (v) => '$v',
                  isSelected: (v) => v == formState.maxBranchesPerNode,
                  onSelected: (v) {
                    formController.updateMaxBranchesPerNode(v);
                    setSheetState(() {});
                  },
                ),
              );
            },
          ),
        );
      },
    );
  }

  List<Widget> buildAllSettings(Translations t) {
    return [buildDepthLevelSetting(t), buildMaxBranchesSetting(t)];
  }
}
