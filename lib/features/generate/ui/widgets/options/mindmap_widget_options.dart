import 'dart:core';

import 'package:datn_mobile/features/generate/states/controller_provider.dart';
import 'package:datn_mobile/features/generate/ui/widgets/shared/setting_item.dart';
import 'package:datn_mobile/i18n/strings.g.dart';
import 'package:datn_mobile/shared/widget/flex_dropdown_field.dart';
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
              return FlexDropdownField<int>(
                value: formState.maxDepth,
                items: availableMaxDepths,
                onChanged: (value) {
                  formController.updateMaxDepth(value);
                  setSheetState(() {});
                },
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
              return FlexDropdownField<int>(
                value: formState.maxBranchesPerNode,
                items: availableMaxBranches,
                onChanged: (value) {
                  formController.updateMaxBranchesPerNode(value);
                  setSheetState(() {});
                },
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
