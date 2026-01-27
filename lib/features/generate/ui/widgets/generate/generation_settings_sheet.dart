import 'package:datn_mobile/features/generate/domain/entity/ai_model.dart';

import 'package:datn_mobile/features/generate/states/controller_provider.dart';
import 'package:datn_mobile/features/generate/ui/widgets/shared/picker_bottom_sheet.dart';
import 'package:datn_mobile/features/generate/ui/widgets/shared/setting_item.dart';
import 'package:datn_mobile/i18n/strings.g.dart';
import 'package:datn_mobile/shared/pods/translation_pod.dart';
import 'package:datn_mobile/shared/riverpod_ext/async_value_easy_when.dart';
import 'package:datn_mobile/shared/utils/provider_logo_utils.dart';
import 'package:datn_mobile/shared/widgets/flex_dropdown_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Bottom sheet for configuring presentation generation settings.
class GenerationSettingsSheet extends ConsumerWidget {
  final NotifierProvider formControllerProvider;
  final List<Widget> optionWidgets;
  final List<String> _availableLanguages = ['English', 'Vietnamese'];
  final ModelType modelType;

  GenerationSettingsSheet({
    super.key,
    required this.formControllerProvider,
    required this.optionWidgets,
    required this.modelType,
  });

  /// Shows the generation settings bottom sheet.
  static void show(
    BuildContext context,
    List<Widget> optionWidgets,
    ModelType modelType,
    String title,
    String buttonText,
  ) {
    PickerBottomSheet.show(
      context: context,
      title: title,
      child: GenerationSettingsSheet(
        formControllerProvider: presentationFormControllerProvider,
        optionWidgets: optionWidgets,
        modelType: modelType,
      ),
      saveButton: _buildDoneButton(context, buttonText),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formState = ref.watch(formControllerProvider);
    final formController = ref.read(formControllerProvider.notifier);

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
            (widget) => [widget, const SizedBox(height: 16)],
          ),
          _buildLanguageSetting(formState, formController, t),
          const SizedBox(height: 16),
          _buildModelSetting(ref, formState, formController, modelType, t),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  /// Language setting.
  Widget _buildLanguageSetting(
    dynamic formState,
    dynamic formController,
    Translations t,
  ) {
    return SettingItem(
      label: t.generate.mindmapGenerate.selectLanguage,
      child: StatefulBuilder(
        builder: (context, setSheetState) {
          return FlexDropdownField<String>(
            value: formState.language,
            items: _availableLanguages,
            onChanged: (value) {
              formController.updateLanguage(value);
              setSheetState(() {});
            },
          );
        },
      ),
    );
  }

  /// AI model setting with async loading from modelsControllerPod.
  Widget _buildModelSetting(
    WidgetRef ref,
    dynamic formState,
    dynamic formController,
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
                  final selectedModel = models.firstWhere(
                    (m) =>
                        m.displayName ==
                        (formState.outlineModel?.displayName ??
                            models.first.displayName),
                    orElse: () => models.first,
                  );

                  return FlexDropdownField<AIModel>(
                    value: selectedModel,
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
                      formController.updateOutlineModel(model);
                      setSheetState(() {});
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
