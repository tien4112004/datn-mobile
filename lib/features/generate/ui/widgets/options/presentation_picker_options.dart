import 'dart:core';

import 'package:datn_mobile/features/generate/ui/widgets/shared/picker_bottom_sheet.dart';
import 'package:flutter/material.dart';

class PresentationPickerOptions {
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

  static void showSlideCountPicker(
    dynamic formController,
    dynamic formState,
    BuildContext context,
    dynamic t,
  ) {
    PickerBottomSheet.show(
      context: context,
      title: t.generate.presentationGenerate.selectSlideCount,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: availableSlideCounts.map((count) {
          final isSelected = formState.slideCount == count;
          return ListTile(
            title: Text(
              t.generate.presentationGenerate.slidesCount(count: count),
            ),
            trailing: isSelected
                ? Icon(
                    Icons.check_circle_rounded,
                    color: Theme.of(context).colorScheme.primary,
                  )
                : null,
            onTap: () {
              formController.updateSlideCount(count);
              Navigator.pop(context);
            },
          );
        }).toList(),
      ),
    );
  }
}
