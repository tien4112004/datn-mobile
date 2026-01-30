import 'dart:core';

import 'package:AIPrimary/features/generate/ui/widgets/shared/picker_bottom_sheet.dart';
import 'package:flutter/material.dart';

class MindmapPickerOptions {
  static List<int> availableMaxDepths = [1, 2, 3, 4, 5];
  static List<int> availableMaxBranches = [2, 3, 4, 5, 6, 7, 8, 9, 10];

  static void showMaxDepthPicker(
    BuildContext context,
    dynamic formState,
    dynamic formController,
    dynamic t,
  ) {
    PickerBottomSheet.show(
      context: context,
      title: t.generate.mindmapGenerate.selectMaxDepth,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: availableMaxDepths.map((depth) {
          final isSelected = formState.maxDepth == depth;
          return ListTile(
            title: Text(t.generate.mindmapGenerate.maxDepth(depth: depth)),
            trailing: isSelected
                ? Icon(
                    Icons.check_circle_rounded,
                    color: Theme.of(context).colorScheme.primary,
                  )
                : null,
            onTap: () {
              formController.updateMaxDepth(depth);
              Navigator.pop(context);
            },
          );
        }).toList(),
      ),
    );
  }

  static void showMaxBranchesPicker(
    BuildContext context,
    dynamic formState,
    dynamic formController,
    dynamic t,
  ) {
    PickerBottomSheet.show(
      context: context,
      title: t.generate.mindmapGenerate.selectMaxBranches,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: availableMaxBranches.map((branches) {
          final isSelected = formState.maxBranchesPerNode == branches;
          return ListTile(
            title: Text(
              t.generate.mindmapGenerate.maxBranches(branches: branches),
            ),
            trailing: isSelected
                ? Icon(
                    Icons.check_circle_rounded,
                    color: Theme.of(context).colorScheme.primary,
                  )
                : null,
            onTap: () {
              formController.updateMaxBranchesPerNode(branches);
              Navigator.pop(context);
            },
          );
        }).toList(),
      ),
    );
  }
}
