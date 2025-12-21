import 'package:datn_mobile/core/theme/app_theme.dart';
import 'package:datn_mobile/features/generate/domain/entity/ai_model.dart';

import 'package:datn_mobile/features/generate/states/controller_provider.dart';
import 'package:datn_mobile/features/generate/ui/widgets/shared/setting_item.dart';
import 'package:datn_mobile/i18n/strings.g.dart';
import 'package:datn_mobile/shared/pods/translation_pod.dart';
import 'package:datn_mobile/shared/widget/dropdown_field.dart';
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
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: context.surfaceColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => GenerationSettingsSheet(
        formControllerProvider: presentationFormControllerProvider,
        optionWidgets: optionWidgets,
        modelType: modelType,
      ),
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
      child: Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHandle(context),
            const SizedBox(height: 20),
            _buildTitle(context, t),
            const SizedBox(height: 20),
            ...optionWidgets.expand(
              (widget) => [widget, const SizedBox(height: 16)],
            ),
            _buildLanguageSetting(formState, formController, t),
            const SizedBox(height: 16),
            _buildModelSetting(ref, formState, formController, modelType, t),
            const SizedBox(height: 24),
            _buildDoneButton(context, t),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  /// Drag handle at the top of the sheet.
  Widget _buildHandle(BuildContext context) {
    return Center(
      child: Container(
        width: 40,
        height: 4,
        decoration: BoxDecoration(
          color: context.isDarkMode ? Colors.grey[700] : Colors.grey[300],
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }

  /// Sheet title.
  Widget _buildTitle(BuildContext context, Translations t) {
    return Text(
      t.generate.generationSettings.title,
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: context.isDarkMode ? Colors.white : Colors.grey[900],
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
          return DropdownField<String>(
            value: formState.language,
            items: _availableLanguages,
            onChanged: (value) {
              if (value != null) {
                formController.updateLanguage(value);
                setSheetState(() {});
              }
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
          return modelsAsync.when(
            data: (state) {
              final models = state.availableModels
                  .where((m) => m.isEnabled)
                  .toList();
              if (models.isEmpty) {
                return Text(t.generate.mindmapGenerate.noModelsAvailable);
              }
              final displayNames = models.map((m) => m.displayName).toList();
              final currentValue =
                  formState.outlineModel?.displayName ??
                  models.first.displayName;
              return StatefulBuilder(
                builder: (context, setSheetState) {
                  return DropdownField<String>(
                    value: currentValue,
                    items: displayNames,
                    onChanged: (value) {
                      if (value != null) {
                        final model = models.firstWhere(
                          (m) => m.displayName == value,
                        );
                        formController.updateOutlineModel(model);
                        setSheetState(() {});
                      }
                    },
                  );
                },
              );
            },
            loading: () => const SizedBox(
              height: 48,
              child: Center(
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            ),
            error: (_, _) =>
                Text(t.generate.mindmapGenerate.failedToLoadModels),
          );
        },
      ),
    );
  }

  /// Done button to close the sheet.
  Widget _buildDoneButton(BuildContext context, Translations t) {
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
        child: Text(t.generate.generationSettings.done),
      ),
    );
  }
}
