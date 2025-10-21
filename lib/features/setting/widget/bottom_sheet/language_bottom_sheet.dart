import 'package:datn_mobile/shared/helper/option_bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:datn_mobile/shared/pods/translation_pod.dart';
import 'package:datn_mobile/i18n/strings.g.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

void showLanguageBottomSheet(BuildContext context, WidgetRef ref) {
  final t = ref.read(translationsPod);
  final currentLocale = t.$meta.locale;

  showOptionBottomSheet<AppLocale>(
    context: context,
    title: t.settings.languageBottomSheet.title,
    options: AppLocale.values,
    currentValue: currentLocale,
    showLoadingOverlay: true,
    overlayDelay: const Duration(milliseconds: 1250),
    onOptionSelected: (locale) async {
      final update = switch (locale) {
        AppLocale.en => await AppLocale.en.build(),
        AppLocale.vi => await AppLocale.vi.build(),
      };
      ref.read(translationsPod.notifier).update((state) => update);
    },
    getOptionLabel: (locale) {
      return locale == AppLocale.en
          ? t.settings.languageBottomSheet.english
          : t.settings.languageBottomSheet.vietnamese;
    },
    getOptionIcon: (locale) => LucideIcons.languages,
  );
}
