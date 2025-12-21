import 'dart:core';

import 'package:datn_mobile/features/generate/states/controller_provider.dart';
import 'package:datn_mobile/features/generate/ui/widgets/shared/setting_item.dart';
import 'package:datn_mobile/i18n/strings.g.dart';
import 'package:datn_mobile/shared/widget/dropdown_field.dart';
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
              return DropdownField<int>(
                value: formPresentationState.slideCount,
                items: availableSlideCounts,
                onChanged: (value) {
                  if (value != null) {
                    formController.updateSlideCount(value);
                    setSheetState(() {});
                  }
                },
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
