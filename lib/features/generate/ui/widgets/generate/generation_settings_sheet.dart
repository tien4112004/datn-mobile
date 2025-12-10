import 'package:datn_mobile/core/theme/app_theme.dart';
import 'package:datn_mobile/features/generate/states/models_controller_pod.dart';
import 'package:datn_mobile/features/generate/domain/entity/ai_model.dart';

import 'package:datn_mobile/features/generate/states/controller_provider.dart';
import 'package:datn_mobile/shared/widget/dropdown_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Available languages for presentation generation
const List<String> _availableLanguages = ['English', 'Vietnamese'];

/// Available slide counts for presentation generation
const List<int> _availableSlideCounts = [3, 4, 5, 7, 10, 12, 15, 20, 25, 30];

/// Bottom sheet for configuring presentation generation settings.
///
/// Extracted from PresentationGeneratePage to improve code organization.
/// Allows users to configure slide count, language, and AI model.
class GenerationSettingsSheet extends ConsumerWidget {
  const GenerationSettingsSheet({super.key});

  /// Shows the generation settings bottom sheet.
  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: context.surfaceColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => const GenerationSettingsSheet(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formState = ref.watch(presentationFormControllerProvider);
    final formController = ref.read(
      presentationFormControllerProvider.notifier,
    );

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
            _buildTitle(context),
            const SizedBox(height: 20),
            _buildSlideCountSetting(formState, formController),
            const SizedBox(height: 16),
            _buildLanguageSetting(formState, formController),
            const SizedBox(height: 16),
            _buildModelSetting(ref, formState, formController),
            const SizedBox(height: 24),
            _buildDoneButton(context),
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
  Widget _buildTitle(BuildContext context) {
    return Text(
      'Generation Settings',
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: context.isDarkMode ? Colors.white : Colors.grey[900],
      ),
    );
  }

  /// Slide count setting.
  Widget _buildSlideCountSetting(dynamic formState, dynamic formController) {
    return _SettingItem(
      label: 'Number of Slides',
      child: StatefulBuilder(
        builder: (context, setSheetState) {
          return DropdownField<int>(
            value: formState.slideCount,
            items: _availableSlideCounts,
            onChanged: (value) {
              if (value != null) {
                formController.updateSlideCount(value);
                setSheetState(() {});
              }
            },
          );
        },
      ),
    );
  }

  /// Language setting.
  Widget _buildLanguageSetting(dynamic formState, dynamic formController) {
    return _SettingItem(
      label: 'Language',
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
  ) {
    return _SettingItem(
      label: 'AI Model',
      child: Consumer(
        builder: (context, ref, _) {
          final modelsAsync = ref.watch(modelsControllerPod(ModelType.text));
          return modelsAsync.when(
            data: (state) {
              final models = state.availableModels
                  .where((m) => m.isEnabled)
                  .toList();
              if (models.isEmpty) {
                return const Text('No models available');
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
            error: (_, _) => const Text('Failed to load models'),
          );
        },
      ),
    );
  }

  /// Done button to close the sheet.
  Widget _buildDoneButton(BuildContext context) {
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
        child: const Text('Done'),
      ),
    );
  }
}

/// Internal widget for displaying a labeled setting field.
class _SettingItem extends StatelessWidget {
  final String label;
  final Widget child;

  const _SettingItem({required this.label, required this.child});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: context.secondaryTextColor,
          ),
        ),
        const SizedBox(height: 8),
        child,
      ],
    );
  }
}
