import 'dart:core';

import 'package:AIPrimary/features/generate/data/dto/art_style_dto.dart';
import 'package:AIPrimary/features/generate/states/art_style/art_style_provider.dart';
import 'package:AIPrimary/features/generate/states/controller_provider.dart';
import 'package:AIPrimary/features/generate/ui/widgets/options/art_style_picker.dart';
import 'package:AIPrimary/features/generate/ui/widgets/options/general_picker_options.dart';
import 'package:AIPrimary/features/generate/ui/widgets/shared/picker_bottom_sheet.dart';
import 'package:AIPrimary/features/generate/ui/widgets/shared/setting_item.dart';
import 'package:AIPrimary/i18n/strings.g.dart';
import 'package:AIPrimary/shared/riverpod_ext/async_value_easy_when.dart';
import 'package:AIPrimary/shared/widgets/picker_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ImageWidgetOptions {
  static List<String> get availableAspectRatios => [
    '1:1',
    '16:9',
    '9:16',
    '4:3',
    '3:4',
  ];

  /// Aspect ratio setting.
  static Widget buildAspectRatioSetting(Translations t) {
    return Consumer(
      builder: (context, ref, _) {
        final formState = ref.watch(imageFormControllerProvider);
        final formController = ref.read(imageFormControllerProvider.notifier);

        return SettingItem(
          label: t.generate.imageGenerate.selectAspectRatio,
          child: StatefulBuilder(
            builder: (context, setSheetState) {
              return PickerButton(
                label: formState.aspectRatio,
                onTap: () => GeneralPickerOptions.showEnumPicker<String>(
                  context: context,
                  title: t.generate.imageGenerate.selectAspectRatio,
                  values: availableAspectRatios,
                  labelOf: (v) => v,
                  isSelected: (v) => v == formState.aspectRatio,
                  onSelected: (v) {
                    formController.updateAspectRatio(v);
                    setSheetState(() {});
                  },
                ),
              );
            },
          ),
        );
      },
    );
  }

  /// Art style setting.
  static Widget buildArtStyleSetting(Translations t) {
    return Consumer(
      builder: (context, ref, _) {
        final formState = ref.watch(imageFormControllerProvider);
        final formController = ref.read(imageFormControllerProvider.notifier);
        final artStylesAsync = ref.watch(artStylesProvider);

        return SettingItem(
          label: t.generate.imageGenerate.selectArtStyle,
          child: artStylesAsync.easyWhen(
            data: (artStyles) {
              // Resolve display label for the current selection
              final selectedStyle = formState.artStyle;
              final String currentLabel;
              if (selectedStyle.isEmpty) {
                currentLabel = 'None';
              } else {
                final match = artStyles.cast<ArtStyleDto?>().firstWhere(
                  (s) => s?.id == selectedStyle,
                  orElse: () => null,
                );
                currentLabel = match?.name ?? 'None';
              }

              return PickerButton(
                label: currentLabel,
                onTap: () {
                  final stylesWithNone = [ArtStyleDto.empty(), ...artStyles];
                  PickerBottomSheet.show(
                    context: context,
                    title: t.generate.imageGenerate.selectArtStyle,
                    subTitle:
                        'Choose the visual style for your presentation images',
                    child: Container(
                      padding: const EdgeInsets.all(24),
                      child: SingleChildScrollView(
                        child: ArtStylePicker(
                          selectedArtStyleId: selectedStyle,
                          artStyles: stylesWithNone,
                          onStyleSelected: (selectedStyleId) {
                            formController.updateArtStyle(selectedStyleId);
                            Navigator.pop(context);
                          },
                        ),
                      ),
                    ),
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
          ),
        );
      },
    );
  }

  List<Widget> buildAllSettings(Translations t) {
    return [buildAspectRatioSetting(t), buildArtStyleSetting(t)];
  }
}
