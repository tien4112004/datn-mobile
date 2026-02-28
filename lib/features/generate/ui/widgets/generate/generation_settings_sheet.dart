import 'package:AIPrimary/features/generate/domain/entity/ai_model.dart';
import 'package:AIPrimary/features/generate/ui/widgets/shared/model_picker_sheet.dart';
import 'package:AIPrimary/features/generate/ui/widgets/shared/picker_bottom_sheet.dart';
import 'package:AIPrimary/features/generate/ui/widgets/shared/setting_item.dart';
import 'package:AIPrimary/i18n/strings.g.dart';
import 'package:AIPrimary/shared/models/language_enums.dart';
import 'package:AIPrimary/shared/pods/translation_pod.dart';
import 'package:AIPrimary/shared/widgets/picker_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Bottom sheet for configuring generation settings.
class GenerationSettingsSheet extends ConsumerWidget {
  final List<Widget> optionWidgets;
  final ModelType modelType;

  final String? language;
  final ValueChanged<String>? onLanguageChanged;
  final AIModel? selectedModel;
  final ValueChanged<AIModel>? onModelChanged;

  const GenerationSettingsSheet({
    super.key,
    required this.optionWidgets,
    required this.modelType,
    this.language,
    this.onLanguageChanged,
    this.selectedModel,
    this.onModelChanged,
  });

  /// Shows the generation settings bottom sheet.
  static void show({
    required BuildContext context,
    required List<Widget> optionWidgets,
    required ModelType modelType,
    required String title,
    required String buttonText,
    String? language,
    ValueChanged<String>? onLanguageChanged,
    AIModel? selectedModel,
    ValueChanged<AIModel>? onModelChanged,
  }) {
    PickerBottomSheet.show(
      context: context,
      title: title,
      child: GenerationSettingsSheet(
        optionWidgets: optionWidgets,
        modelType: modelType,
        language: language,
        onLanguageChanged: onLanguageChanged,
        selectedModel: selectedModel,
        onModelChanged: onModelChanged,
      ),
      saveButton: _buildDoneButton(context, buttonText),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(translationsPod);

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (language != null && onLanguageChanged != null) ...[
            _buildLanguageSetting(language!, onLanguageChanged!, t),
            const SizedBox(height: 16),
          ],
          if (onModelChanged != null) ...[
            _buildModelSetting(selectedModel, onModelChanged!, modelType, t),
            const SizedBox(height: 24),
          ],
          ...optionWidgets.expand(
            (widget) => [widget, const SizedBox(height: 8)],
          ),
        ],
      ),
    );
  }

  /// Language setting — opens a picker bottom sheet.
  Widget _buildLanguageSetting(
    String currentLanguage,
    ValueChanged<String> onChanged,
    Translations t,
  ) {
    return SettingItem(
      label: t.generate.mindmapGenerate.selectLanguage,
      child: StatefulBuilder(
        builder: (context, setSheetState) {
          return PickerButton(
            label: Language.fromApiValue(currentLanguage).getDisplayName(t),
            onTap: () => PickerBottomSheet.show(
              context: context,
              title: t.generate.mindmapGenerate.selectLanguage,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: Language.values.map((lang) {
                  final isSelected = currentLanguage == lang.apiValue;
                  return ListTile(
                    title: Text(lang.getDisplayName(t)),
                    trailing: isSelected
                        ? Icon(
                            Icons.check_circle_rounded,
                            color: Theme.of(context).colorScheme.primary,
                          )
                        : null,
                    onTap: () {
                      onChanged(lang.apiValue);
                      setSheetState(() => currentLanguage = lang.apiValue);
                      Navigator.pop(context);
                    },
                  );
                }).toList(),
              ),
            ),
          );
        },
      ),
    );
  }

  /// AI model setting — opens a [ModelPickerSheet] bottom sheet.
  Widget _buildModelSetting(
    AIModel? currentModel,
    ValueChanged<AIModel> onModelChanged,
    ModelType modelType,
    Translations t,
  ) {
    return SettingItem(
      label: t.generate.mindmapGenerate.selectModel,
      child: StatefulBuilder(
        builder: (context, setSheetState) {
          return PickerButton(
            label:
                currentModel?.displayName ??
                t.generate.mindmapGenerate.selectModel,
            onTap: () => ModelPickerSheet.show(
              context: context,
              title: t.generate.mindmapGenerate.selectModel,
              selectedModelName: currentModel?.displayName,
              t: t,
              onModelSelected: (model) {
                onModelChanged(model);
                setSheetState(() => currentModel = model);
              },
              modelType: modelType,
            ),
          );
        },
      ),
    );
  }

  /// Done button to close the sheet.
  static Widget _buildDoneButton(BuildContext context, String buttonText) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () => Navigator.pop(context),
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(buttonText),
      ),
    );
  }
}
