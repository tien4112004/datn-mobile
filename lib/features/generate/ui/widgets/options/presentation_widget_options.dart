import 'dart:core';

import 'package:AIPrimary/features/generate/states/controller_provider.dart';
import 'package:AIPrimary/features/generate/ui/widgets/options/general_picker_options.dart';
import 'package:AIPrimary/features/generate/ui/widgets/shared/setting_item.dart';
import 'package:AIPrimary/i18n/strings.g.dart';
import 'package:AIPrimary/shared/models/cms_enums.dart';
import 'package:AIPrimary/shared/widgets/picker_button.dart';
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
              return PickerButton(
                label: '${formPresentationState.slideCount}',
                onTap: () => GeneralPickerOptions.showEnumPicker<int>(
                  context: context,
                  title: t.generate.presentationGenerate.selectSlideCount,
                  values: availableSlideCounts,
                  labelOf: (v) => '$v',
                  isSelected: (v) => v == formPresentationState.slideCount,
                  onSelected: (v) {
                    formController.updateSlideCount(v);
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

  static Widget buildGradeSetting(Translations t) {
    return Consumer(
      builder: (context, ref, _) {
        final formState = ref.watch(presentationFormControllerProvider);
        final formController = ref.read(
          presentationFormControllerProvider.notifier,
        );
        final gradeOptions = [null, ...GradeLevel.values];

        return SettingItem(
          label: t.generate.presentationGenerate.grade,
          child: StatefulBuilder(
            builder: (context, setSheetState) {
              final currentLabel = formState.grade == null
                  ? t.generate.presentationGenerate.none
                  : GradeLevel.fromApiValue(
                      formState.grade!,
                    ).getLocalizedName(t);

              return PickerButton(
                label: currentLabel,
                onTap: () => GeneralPickerOptions.showEnumPicker<GradeLevel?>(
                  context: context,
                  title: t.generate.presentationGenerate.grade,
                  values: gradeOptions,
                  labelOf: (g) => g == null
                      ? t.generate.presentationGenerate.none
                      : g.getLocalizedName(t),
                  isSelected: (g) => g?.apiValue == formState.grade,
                  onSelected: (g) {
                    formController.updateGrade(g?.apiValue);
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

  static Widget buildSubjectSetting(Translations t) {
    return Consumer(
      builder: (context, ref, _) {
        final formState = ref.watch(presentationFormControllerProvider);
        final formController = ref.read(
          presentationFormControllerProvider.notifier,
        );
        final subjectOptions = [null, ...Subject.values];

        return SettingItem(
          label: t.generate.presentationGenerate.subject,
          child: StatefulBuilder(
            builder: (context, setSheetState) {
              final currentLabel = formState.subject == null
                  ? t.generate.presentationGenerate.none
                  : Subject.fromApiValue(
                      formState.subject!,
                    ).getLocalizedName(t);

              return PickerButton(
                label: currentLabel,
                onTap: () => GeneralPickerOptions.showEnumPicker<Subject?>(
                  context: context,
                  title: t.generate.presentationGenerate.subject,
                  values: subjectOptions,
                  labelOf: (s) => s == null
                      ? t.generate.presentationGenerate.none
                      : s.getLocalizedName(t),
                  isSelected: (s) => s?.apiValue == formState.subject,
                  onSelected: (s) {
                    formController.updateSubject(s?.apiValue);
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
    return [
      buildSlideCountSetting(t),
      buildGradeSetting(t),
      buildSubjectSetting(t),
    ];
  }
}
