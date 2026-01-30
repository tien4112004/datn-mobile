import 'dart:core';

import 'package:AIPrimary/features/generate/ui/widgets/shared/picker_bottom_sheet.dart';
import 'package:AIPrimary/i18n/strings.g.dart';
import 'package:flutter/material.dart';

class ImagePickerOptions {
  static List<String> get availableAspectRatios => [
    '1:1',
    '16:9',
    '9:16',
    '4:3',
    '3:4',
  ];

  /// Aspect ratio setting.
  static void showRatioImage(
    BuildContext context,
    dynamic formController,
    dynamic formState,
    Translations t,
  ) {
    PickerBottomSheet.show(
      context: context,
      title: 'Aspect Ratio',
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: availableAspectRatios.map((ratio) {
          final isSelected = formState.aspectRatio == ratio;
          return ListTile(
            title: Text(ratio),
            trailing: isSelected
                ? Icon(
                    Icons.check_circle_rounded,
                    color: Theme.of(context).colorScheme.primary,
                  )
                : null,
            onTap: () {
              formController.updateAspectRatio(ratio);
              Navigator.pop(context);
            },
          );
        }).toList(),
      ),
    );
  }
}
