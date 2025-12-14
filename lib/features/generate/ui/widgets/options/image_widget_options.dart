import 'dart:core';

import 'package:datn_mobile/features/generate/states/controller_provider.dart';
import 'package:datn_mobile/features/generate/ui/widgets/shared/setting_item.dart';
import 'package:datn_mobile/i18n/strings.g.dart';
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
  static Widget buildAspectRatioSetting(Translations t) {
    return Consumer(
      builder: (context, ref, _) {
        final formState = ref.watch(imageFormControllerProvider);
        final formController = ref.read(imageFormControllerProvider.notifier);

        return SettingItem(
          label: t.generate.imageGenerate.selectAspectRatio,
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
  static Widget buildArtStyleSetting(Translations t) {
    return Consumer(
      builder: (context, ref, _) {
        final formState = ref.watch(imageFormControllerProvider);
        final formController = ref.read(imageFormControllerProvider.notifier);

        return SettingItem(
          label: t.generate.imageGenerate.selectArtStyle,
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
  static Widget buildThemeStyleSetting(Translations t) {
    return Consumer(
      builder: (context, ref, _) {
        final formState = ref.watch(imageFormControllerProvider);
        final formController = ref.read(imageFormControllerProvider.notifier);

        return SettingItem(
          label: t.generate.imageGenerate.selectThemeStyle,
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

  List<Widget> buildAllSettings(Translations t) {
    return [
      buildAspectRatioSetting(t),
      buildArtStyleSetting(t),
      buildThemeStyleSetting(t),
    ];
  }
}
