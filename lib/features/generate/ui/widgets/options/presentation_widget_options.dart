import 'dart:core';

import 'package:AIPrimary/features/generate/states/controller_provider.dart';
import 'package:AIPrimary/features/generate/ui/widgets/shared/setting_item.dart';
import 'package:AIPrimary/i18n/strings.g.dart';
import 'package:AIPrimary/shared/models/cms_enums.dart';
import 'package:AIPrimary/shared/widgets/flex_dropdown_field.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PresentationWidgetOptions {
  static List<int> get availableSlideCounts => [
    3,
    4,
    5,
    7,
    10,
    12,
    15,
    20,
    25,
    30,
  ];

  /// Slide count setting.
  static Widget buildSlideCountSetting(Translations t) {
    return Consumer(
      builder: (context, ref, _) {
        final formPresentationState = ref.watch(
          presentationFormControllerProvider,
        );
        final formController = ref.read(
          presentationFormControllerProvider.notifier,
        );

        return SettingItem(
          label: t.generate.presentationGenerate.selectSlideCount,
          child: StatefulBuilder(
            builder: (context, setSheetState) {
              return FlexDropdownField<int>(
                value: formPresentationState.slideCount,
                items: availableSlideCounts,
                onChanged: (value) {
                  formController.updateSlideCount(value);
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
        final formState = ref.watch(presentationFormControllerProvider);
        final formController = ref.read(
          presentationFormControllerProvider.notifier,
        );

        return SettingItem(
          label: t.generate.presentationGenerate.grade,
          child: StatefulBuilder(
            builder: (context, setSheetState) {
              return FlexDropdownField<String?>(
                value: formState.grade,
                items: [null, ...GradeLevel.values.map((g) => g.apiValue)],
                itemLabelBuilder: (v) {
                  if (v == null) return t.generate.presentationGenerate.none;
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
        final formState = ref.watch(presentationFormControllerProvider);
        final formController = ref.read(
          presentationFormControllerProvider.notifier,
        );

        return SettingItem(
          label: t.generate.presentationGenerate.subject,
          child: StatefulBuilder(
            builder: (context, setSheetState) {
              return FlexDropdownField<String?>(
                value: formState.subject,
                items: [null, ...Subject.values.map((s) => s.apiValue)],
                itemLabelBuilder: (v) {
                  if (v == null) return t.generate.presentationGenerate.none;
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
      buildSlideCountSetting(t),
      buildGradeSetting(t),
      buildSubjectSetting(t),
    ];
  }
}
