import 'package:AIPrimary/features/generate/domain/entity/ai_model.dart';
import 'package:AIPrimary/features/generate/ui/widgets/generate/option_chip.dart';
import 'package:AIPrimary/features/generate/ui/widgets/shared/model_picker_sheet.dart';
import 'package:AIPrimary/features/generate/ui/widgets/shared/picker_bottom_sheet.dart';
import 'package:AIPrimary/i18n/strings.g.dart';
import 'package:flutter/material.dart';

class GeneralPickerOptions {
  static void showLanguagePicker(
    BuildContext context,
    dynamic formController,
    dynamic formState,
    dynamic t,
  ) {
    /// Available languages for presentation generation
    List<String> availableLanguages = [t.locale_en, t.locale_vi];

    PickerBottomSheet.show(
      context: context,
      title: t.generate.presentationGenerate.selectLanguage,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: availableLanguages.map((language) {
          final isSelected = formState.language == language;
          return ListTile(
            title: Text(language),
            trailing: isSelected
                ? Icon(
                    Icons.check_circle_rounded,
                    color: Theme.of(context).colorScheme.primary,
                  )
                : null,
            onTap: () {
              formController.updateLanguage(language);
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
