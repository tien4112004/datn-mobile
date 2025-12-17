import 'dart:core';

import 'package:datn_mobile/features/generate/states/controller_provider.dart';
import 'package:datn_mobile/features/generate/ui/widgets/options/art_style_picker.dart';
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

  static List<String> get availableArtStyles => [
    'Cartoon',
    'Realistic',
    'Oil painting',
    'Watercolor',
    'Sketch',
  ];

  /// Map art styles to their visual colors
  static Map<String, Color> get artStyleColors => {
    'cartoon': const Color(0xFF00BCD4),
    'realistic': const Color(0xFF2196F3),
    'oil painting': const Color(0xFF5C6BC0),
    'watercolor': const Color(0xFF42A5F5),
    'sketch': const Color(0xFF90CAF9),
  };

  /// Map art styles to their icons
  static Map<String, IconData> get artStyleIcons => {
    'cartoon': Icons.sentiment_very_satisfied,
    'realistic': Icons.camera_alt,
    'oil painting': Icons.brush,
    'watercolor': Icons.water_drop,
    'sketch': Icons.draw,
  };

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
        final selectedStyle = formState.artStyle;

        return SettingItem(
          label: t.generate.imageGenerate.selectArtStyle,
          child: GestureDetector(
            onTap: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                builder: (context) => Container(
                  padding: const EdgeInsets.all(24),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          t.generate.imageGenerate.selectArtStyle,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Choose the visual style for your presentation images',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 20),
                        ArtStylePicker(
                          selectedArtStyle: selectedStyle,
                          availableArtStyles: availableArtStyles,
                          styleColors: artStyleColors,
                          styleIcons: artStyleIcons,
                          onStyleSelected: (selectedStyle) {
                            formController.updateArtStyle(selectedStyle);
                            Navigator.pop(context);
                          },
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),
              );
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
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
                          color: artStyleColors[selectedStyle] ?? Colors.grey,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Icon(
                          artStyleIcons[selectedStyle] ?? Icons.palette,
                          color: Colors.white,
                          size: 14,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        selectedStyle.replaceAll('_', ' '),
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                  Icon(Icons.chevron_right, color: Colors.grey[400]),
                ],
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
