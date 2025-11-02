import 'package:datn_mobile/shared/helper/option_bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:datn_mobile/core/theme/theme_controller.dart';
import 'package:datn_mobile/shared/pods/translation_pod.dart';

void showThemeBottomSheet(BuildContext context, WidgetRef ref) {
  final t = ref.read(translationsPod);
  final currentTheme = ref.read(themeControllerProvider);

  final showBottomSheet = showOptionBottomSheet<ThemeMode>(
    context: context,
    title: t.settings.themeBottomSheet.title,
    options: ThemeMode.values,
    currentValue: currentTheme,
    showLoadingOverlay: true,
    overlayDelay: const Duration(milliseconds: 1250),
    onOptionSelected: (themeMode) async {
      ref.read(themeControllerProvider.notifier).changeTheme(themeMode);
    },
    getOptionLabel: (themeMode) {
      return switch (themeMode) {
        ThemeMode.light => t.settings.themeBottomSheet.light,
        ThemeMode.dark => t.settings.themeBottomSheet.dark,
        ThemeMode.system => t.settings.themeBottomSheet.system,
      };
    },
    getOptionIcon: (themeMode) {
      return switch (themeMode) {
        ThemeMode.light => Icons.light_mode,
        ThemeMode.dark => Icons.dark_mode,
        ThemeMode.system => Icons.brightness_auto,
      };
    },
    getOptionDescription: (themeMode) {
      return switch (themeMode) {
        ThemeMode.light => t.settings.themeBottomSheet.lightDescription,
        ThemeMode.dark => t.settings.themeBottomSheet.darkDescription,
        ThemeMode.system => t.settings.themeBottomSheet.systemDescription,
      };
    },
  );
}
