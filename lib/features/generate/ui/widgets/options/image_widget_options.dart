import 'dart:core';

import 'package:datn_mobile/features/generate/states/controller_provider.dart';
import 'package:datn_mobile/features/generate/ui/widgets/shared/setting_item.dart';
import 'package:datn_mobile/shared/widget/dropdown_field.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ImageWidgetOptions {
  static List<String> get availableAspectRatios => [
    '1:1',
    '16:9',
    '9:16',
    '4:3',
    '3:4',
  ];

  static List<String> get availableArtStyles => [
    'cartoon',
    'realistic',
    'oil painting',
    'watercolor',
    'sketch',
  ];

  static List<String> get availableThemeStyles => [
    'light',
    'dark',
    'vibrant',
    'pastel',
    'monochrome',
  ];

  /// Aspect ratio setting.
  static Widget buildAspectRatioSetting() {
    return Consumer(
      builder: (context, ref, _) {
        final formState = ref.watch(imageFormControllerProvider);
        final formController = ref.read(imageFormControllerProvider.notifier);

        return SettingItem(
          label: 'Aspect Ratio',
          child: StatefulBuilder(
            builder: (context, setSheetState) {
              return DropdownField<String>(
                value: formState.aspectRatio,
                items: availableAspectRatios,
                onChanged: (value) {
                  if (value != null) {
                    formController.updateAspectRatio(value);
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

  /// Art style setting.
  static Widget buildArtStyleSetting() {
    return Consumer(
      builder: (context, ref, _) {
        final formState = ref.watch(imageFormControllerProvider);
        final formController = ref.read(imageFormControllerProvider.notifier);

        return SettingItem(
          label: 'Art Style',
          child: StatefulBuilder(
            builder: (context, setSheetState) {
              return DropdownField<String>(
                value: formState.artStyle ?? availableArtStyles.first,
                items: availableArtStyles,
                onChanged: (value) {
                  if (value != null) {
                    formController.updateArtStyle(value);
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

  /// Theme style setting.
  static Widget buildThemeStyleSetting() {
    return Consumer(
      builder: (context, ref, _) {
        final formState = ref.watch(imageFormControllerProvider);
        final formController = ref.read(imageFormControllerProvider.notifier);

        return SettingItem(
          label: 'Theme Style',
          child: StatefulBuilder(
            builder: (context, setSheetState) {
              return DropdownField<String>(
                value: formState.themeStyle ?? availableThemeStyles.first,
                items: availableThemeStyles,
                onChanged: (value) {
                  if (value != null) {
                    formController.updateThemeStyle(value);
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
}
