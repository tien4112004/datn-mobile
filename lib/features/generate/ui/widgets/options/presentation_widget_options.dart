import 'dart:core';

import 'package:AIPrimary/features/generate/states/controller_provider.dart';
import 'package:AIPrimary/features/generate/ui/widgets/options/general_picker_options.dart';
import 'package:AIPrimary/features/generate/ui/widgets/shared/setting_item.dart';
import 'package:AIPrimary/i18n/strings.g.dart';
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

  List<Widget> buildAllSettings(Translations t) {
    return [buildSlideCountSetting(t)];
  }
}
