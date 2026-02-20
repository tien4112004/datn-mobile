import 'package:AIPrimary/features/generate/domain/entity/ai_model.dart';
import 'package:AIPrimary/features/generate/states/controller_provider.dart';
import 'package:AIPrimary/features/generate/ui/widgets/shared/picker_bottom_sheet.dart';
import 'package:AIPrimary/features/generate/ui/widgets/shared/setting_item.dart';
import 'package:AIPrimary/i18n/strings.g.dart';
import 'package:AIPrimary/shared/pods/translation_pod.dart';
import 'package:AIPrimary/shared/riverpod_ext/async_value_easy_when.dart';
import 'package:AIPrimary/shared/utils/provider_logo_utils.dart';
import 'package:AIPrimary/shared/widgets/flex_dropdown_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Bottom sheet for configuring generation settings.
class GenerationSettingsSheet extends ConsumerWidget {
  final List<Widget> optionWidgets;
  final List<String> _availableLanguages = const ['English', 'Vietnamese'];
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
          ...optionWidgets.expand(
            (widget) => [widget, const SizedBox(height: 8)],
          ),
          if (language != null && onLanguageChanged != null) ...[
            _buildLanguageSetting(language!, onLanguageChanged!, t),
            const SizedBox(height: 16),
          ],
          if (onModelChanged != null) ...[
            _buildModelSetting(
              ref,
              selectedModel,
              onModelChanged!,
              modelType,
              t,
            ),
            const SizedBox(height: 24),
          ],
        ],
      ),
    );
  }

  /// Language setting.
  Widget _buildLanguageSetting(
    String currentLanguage,
    ValueChanged<String> onChanged,
    Translations t,
  ) {
    return SettingItem(
      label: t.generate.mindmapGenerate.selectLanguage,
      child: StatefulBuilder(
        builder: (context, setSheetState) {
          return FlexDropdownField<String>(
            value: currentLanguage,
            items: _availableLanguages,
            onChanged: (value) {
              onChanged(value);
              setSheetState(() {
                currentLanguage = value;
              });
            },
          );
        },
      ),
    );
  }

  /// AI model setting with async loading from modelsControllerPod.
  Widget _buildModelSetting(
    WidgetRef ref,
    AIModel? currentModel,
    ValueChanged<AIModel> onModelChanged,
    ModelType modelType,
    Translations t,
  ) {
    return SettingItem(
      label: t.generate.mindmapGenerate.selectModel,
      child: Consumer(
        builder: (context, ref, _) {
          final modelsAsync = ref.watch(modelsControllerPod(modelType));
          return modelsAsync.easyWhen(
            data: (state) {
              final models = state.availableModels
                  .where((m) => m.isEnabled)
                  .toList();
              if (models.isEmpty) {
                return Text(t.generate.mindmapGenerate.noModelsAvailable);
              }

              return StatefulBuilder(
                builder: (context, setSheetState) {
                  var initialModel = models.firstWhere(
                    (m) =>
                        m.displayName ==
                        (currentModel?.displayName ?? models.first.displayName),
                    orElse: () => models.first,
                  );

                  return FlexDropdownField<AIModel>(
                    value: initialModel,
                    items: models,
                    itemBuilder: (context, model) {
                      final logoPath = ProviderLogoUtils.getLogoPath(
                        model.provider,
                      );
                      return Row(
                        children: [
                          Image.asset(logoPath, width: 20, height: 20),
                          const SizedBox(width: 12),
                          Text(
                            model.displayName,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      );
                    },
                    onChanged: (model) {
                      onModelChanged(model);
                      setSheetState(() {
                        initialModel = model;
                      });
                    },
                  );
                },
              );
            },
            loadingWidget: () => const SizedBox(
              height: 48,
              child: Center(
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            ),
            errorWidget: (_, _) =>
                Text(t.generate.mindmapGenerate.failedToLoadModels),
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
