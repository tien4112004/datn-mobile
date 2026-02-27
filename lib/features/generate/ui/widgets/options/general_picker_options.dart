import 'package:AIPrimary/features/generate/domain/entity/ai_model.dart';
import 'package:AIPrimary/features/generate/ui/widgets/generate/option_chip.dart';
import 'package:AIPrimary/features/generate/ui/widgets/shared/model_picker_sheet.dart';
import 'package:AIPrimary/features/generate/ui/widgets/shared/picker_bottom_sheet.dart';
import 'package:AIPrimary/i18n/strings.g.dart';
import 'package:AIPrimary/shared/models/language_enums.dart';
import 'package:flutter/material.dart';

class GeneralPickerOptions {
  static void showLanguagePicker(
    BuildContext context,
    dynamic formController,
    dynamic formState,
    dynamic t,
  ) {
    PickerBottomSheet.show(
      context: context,
      title: t.generate.presentationGenerate.selectLanguage,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: Language.values.map((lang) {
          final isSelected = formState.language == lang.apiValue;
          return ListTile(
            title: Text(lang.getDisplayName(t)),
            trailing: isSelected
                ? Icon(
                    Icons.check_circle_rounded,
                    color: Theme.of(context).colorScheme.primary,
                  )
                : null,
            onTap: () {
              formController.updateLanguage(lang.apiValue);
              Navigator.pop(context);
            },
          );
        }).toList(),
      ),
    );
  }

  static void showModelPicker(
    BuildContext context, {
    required AIModel? selectedModel,
    required ModelType modelType,
    required Function(AIModel) onSelected,
    required Translations t,
  }) {
    ModelPickerSheet.show(
      context: context,
      title: t.generate.presentationGenerate.selectAiModel,
      selectedModelName: selectedModel?.displayName,
      t: t,
      onModelSelected: onSelected,
      modelType: modelType,
    );
  }

  /// Generic picker for any list of values (e.g. enums).
  ///
  /// [title] — title of the bottom sheet
  /// [values] — all available values to pick from
  /// [labelOf] — returns the display label for a value
  /// [isSelected] — returns true if this value is the current selection
  /// [onSelected] — called with the chosen value; the sheet is popped automatically
  static void showEnumPicker<T>({
    required BuildContext context,
    required String title,
    required List<T> values,
    required String Function(T) labelOf,
    required bool Function(T) isSelected,
    required void Function(T) onSelected,
  }) {
    PickerBottomSheet.show(
      context: context,
      title: title,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: values.map((value) {
          final selected = isSelected(value);
          return ListTile(
            title: Text(labelOf(value)),
            trailing: selected
                ? Icon(
                    Icons.check_circle_rounded,
                    color: Theme.of(context).colorScheme.primary,
                  )
                : null,
            onTap: () {
              onSelected(value);
              Navigator.pop(context);
            },
          );
        }).toList(),
      ),
    );
  }

  static Widget buildOptionsRow(
    BuildContext context,
    dynamic formState,
    dynamic formController,
    List<OptionChip> optionChips,
    Translations t,
  ) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      alignment: WrapAlignment.center,
      children: [
        // Slide Count
        ...optionChips,
      ],
    );
  }
}
