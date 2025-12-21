import 'dart:core';

import 'package:datn_mobile/features/generate/data/dto/art_style_dto.dart';
import 'package:datn_mobile/features/generate/states/art_style/art_style_provider.dart';
import 'package:datn_mobile/features/generate/states/controller_provider.dart';
import 'package:datn_mobile/features/generate/ui/widgets/options/art_style_picker.dart';
import 'package:datn_mobile/features/generate/ui/widgets/shared/picker_bottom_sheet.dart';
import 'package:datn_mobile/features/generate/ui/widgets/shared/setting_item.dart';
import 'package:datn_mobile/i18n/strings.g.dart';
import 'package:datn_mobile/shared/widget/dropdown_field.dart';
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
              return DropdownField<String>(
                value: formState.aspectRatio,
                items: availableAspectRatios,
                onChanged: (value) {
                  if (value != null) {
                    formController.updateAspectRatio(value);
                    setSheetState(() {});
                  }
                },
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
        var selectedStyle = formState.artStyle;
        final artStylesAsync = ref.watch(artStylesProvider);

        return SettingItem(
          label: t.generate.imageGenerate.selectArtStyle,
          child: GestureDetector(
            onTap: () {
              PickerBottomSheet.show(
                title: t.generate.imageGenerate.selectArtStyle,
                subTitle: Text(
                  'Choose the visual style for your presentation images',
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
                context: context,
                child: Container(
                  padding: const EdgeInsets.all(24),
                  child: SingleChildScrollView(
                    child: artStylesAsync.when(
                      data: (artStyles) {
                        // Include 'None' option
                        final stylesWithNone = [
                          ArtStyleDto.empty(),
                          ...artStyles,
                        ];
                        return Expanded(
                          child: ArtStylePicker(
                            selectedArtStyleId: selectedStyle,
                            artStyles: stylesWithNone,
                            onStyleSelected: (selectedStyleId) {
                              formController.updateArtStyle(selectedStyleId);
                              Navigator.pop(context);
                            },
                          ),
                        );
                      },
                      loading: () => const Center(
                        child: Padding(
                          padding: EdgeInsets.all(32.0),
                          child: CircularProgressIndicator(strokeWidth: 2.0),
                        ),
                      ),
                      error: (error, stack) => Center(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Text(
                            'Failed to load art styles: $error',
                            style: TextStyle(color: Colors.red[600]),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
            child: artStylesAsync.when(
              data: (artStyles) {
                // Handle 'None' selection
                if (selectedStyle.isEmpty) {
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey[300]!),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 24,
                              height: 24,
                              decoration: BoxDecoration(
                                color: Colors.grey[300],
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Icon(
                                Icons.palette,
                                color: Colors.grey,
                                size: 14,
                              ),
                            ),
                            const SizedBox(width: 12),
                            const Text(
                              'None',
                              style: TextStyle(fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                        Icon(Icons.chevron_right, color: Colors.grey[400]),
                      ],
                    ),
                  );
                }

                if (artStyles.isEmpty) {
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey[300]!),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'No art styles available',
                          style: TextStyle(fontWeight: FontWeight.w500),
                        ),
                        Icon(Icons.chevron_right, color: Colors.grey[400]),
                      ],
                    ),
                  );
                }

                final selectedArtStyle = artStyles.firstWhere(
                  (style) => style.id == selectedStyle,
                  orElse: () => artStyles.first,
                );

                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[300]!),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          if (selectedArtStyle.visual != null)
                            ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: Image.network(
                                selectedArtStyle.visual!,
                                width: 24,
                                height: 24,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    Container(
                                      width: 24,
                                      height: 24,
                                      decoration: BoxDecoration(
                                        color: Colors.grey[300],
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: const Icon(
                                        Icons.palette,
                                        color: Colors.white,
                                        size: 14,
                                      ),
                                    ),
                              ),
                            )
                          else
                            Container(
                              width: 24,
                              height: 24,
                              decoration: BoxDecoration(
                                color: Colors.grey[300],
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Icon(
                                Icons.palette,
                                color: Colors.white,
                                size: 14,
                              ),
                            ),
                          const SizedBox(width: 12),
                          Text(
                            selectedArtStyle.name,
                            style: const TextStyle(fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                      Icon(Icons.chevron_right, color: Colors.grey[400]),
                    ],
                  ),
                );
              },
              loading: () => Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                        SizedBox(width: 12),
                        Text(
                          'Loading...',
                          style: TextStyle(fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                    Icon(Icons.chevron_right, color: Colors.grey),
                  ],
                ),
              ),
              error: (error, stack) => Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.red[300]!),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.error, color: Colors.red[600], size: 20),
                        const SizedBox(width: 12),
                        const Text(
                          'Error loading styles',
                          style: TextStyle(fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                    Icon(Icons.chevron_right, color: Colors.grey[400]),
                  ],
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

  List<Widget> buildAllSettings(Translations t) {
    return [buildAspectRatioSetting(t), buildArtStyleSetting(t)];
  }
}
