import 'dart:core';

import 'package:AIPrimary/features/generate/states/controller_provider.dart';
import 'package:AIPrimary/features/generate/ui/widgets/shared/setting_item.dart';
import 'package:AIPrimary/i18n/strings.g.dart';
import 'package:AIPrimary/shared/models/cms_enums.dart';
import 'package:AIPrimary/shared/widgets/flex_dropdown_field.dart';
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

  static Widget buildGradeSetting(Translations t) {
    return Consumer(
      builder: (context, ref, _) {
        final formState = ref.watch(mindmapFormControllerProvider);
        final formController = ref.read(mindmapFormControllerProvider.notifier);

        return SettingItem(
          label: t.generate.mindmapGenerate.grade,
          child: StatefulBuilder(
            builder: (context, setSheetState) {
              return FlexDropdownField<String?>(
                value: formState.grade,
                items: [null, ...GradeLevel.values.map((g) => g.apiValue)],
                itemLabelBuilder: (v) {
                  if (v == null) return t.generate.mindmapGenerate.none;
                  return GradeLevel.fromApiValue(v).displayName;
                },
                onChanged: (value) {
                  formController.updateGrade(value);
                  setSheetState(() {});
                },
              );
            },
          ),
        );
      },
    );
  }

  static Widget buildSubjectSetting(Translations t) {
    return Consumer(
      builder: (context, ref, _) {
        final formState = ref.watch(mindmapFormControllerProvider);
        final formController = ref.read(mindmapFormControllerProvider.notifier);

        return SettingItem(
          label: t.generate.mindmapGenerate.subject,
          child: StatefulBuilder(
            builder: (context, setSheetState) {
              return FlexDropdownField<String?>(
                value: formState.subject,
                items: [null, ...Subject.values.map((s) => s.apiValue)],
                itemLabelBuilder: (v) {
                  if (v == null) return t.generate.mindmapGenerate.none;
                  return Subject.fromApiValue(v).displayName;
                },
                onChanged: (value) {
                  formController.updateSubject(value);
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
    return [
      buildDepthLevelSetting(t),
      buildMaxBranchesSetting(t),
      buildGradeSetting(t),
      buildSubjectSetting(t),
    ];
  }
}
