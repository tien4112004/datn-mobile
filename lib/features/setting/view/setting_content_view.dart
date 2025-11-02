import 'package:auto_route/auto_route.dart';
import 'package:datn_mobile/core/router/router.gr.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:datn_mobile/core/router/router_pod.dart';
import 'package:datn_mobile/features/setting/widget/bottom_sheet/language_bottom_sheet.dart';
import 'package:datn_mobile/features/setting/widget/bottom_sheet/theme_bottom_sheet.dart';
import 'package:datn_mobile/features/setting/widget/setting_category/setting_option.dart';
import 'package:datn_mobile/features/setting/widget/setting_profile_picture.dart';
import 'package:datn_mobile/features/setting/widget/setting_category/setting_section.dart';
import 'package:datn_mobile/shared/pods/translation_pod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class SettingContentView extends ConsumerWidget {
  const SettingContentView({super.key});

  void _navigateWithFallback(BuildContext context, WidgetRef ref, String path) {
    final autorouter = ref.read(autorouterProvider);
    try {
      autorouter.pushPath(path);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('This page is in development'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(translationsPod);

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SettingProfilePicture(),
            const SizedBox(height: 20),
            SettingSection(
              title: t.accountSetting,
              options: [
                // TODO: Delete this later
                SettingOption(
                  title: "Go to sign in",
                  onPressed: () => {context.router.push(const SignInRoute())},
                ),
                SettingOption(
                  title: t.personalInformation,
                  onPressed: () => _navigateWithFallback(
                    context,
                    ref,
                    'personal-information',
                  ),
                  icon: LucideIcons.user,
                ),
                SettingOption(
                  title: t.passwordAndSecurity,
                  onPressed: () => _navigateWithFallback(
                    context,
                    ref,
                    'password-and-security',
                  ),
                  icon: LucideIcons.lock,
                ),
                SettingOption(
                  title: t.paymentMethods,
                  onPressed: () =>
                      _navigateWithFallback(context, ref, 'payment-methods'),
                  icon: LucideIcons.creditCard,
                ),
              ],
            ),
            SettingSection(
              title: t.settings.appSettings,
              options: [
                SettingOption(
                  title: t.settings.notifications,
                  onPressed: () => _navigateWithFallback(
                    context,
                    ref,
                    'notification-settings',
                  ),
                  icon: LucideIcons.bell,
                ),
                SettingOption(
                  title: t.settings.language,
                  onPressed: () => showLanguageBottomSheet(context, ref),
                  icon: LucideIcons.earth,
                ),
                SettingOption(
                  title: t.settings.theme,
                  onPressed: () => showThemeBottomSheet(context, ref),
                  icon: LucideIcons.palette,
                ),
              ],
            ),
            SettingSection(
              title: t.settings.support,
              options: [
                SettingOption(
                  title: t.settings.helpCenter,
                  onPressed: () =>
                      _navigateWithFallback(context, ref, 'help-center'),
                  icon: LucideIcons.headphones,
                ),
                SettingOption(
                  title: t.settings.contactUs,
                  onPressed: () =>
                      _navigateWithFallback(context, ref, 'contact-us'),
                  icon: LucideIcons.mail,
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 12.0,
              ),
              child: SizedBox(
                width: double.infinity,
                height: 48.0,
                child: ElevatedButton(
                  onPressed: () {},
                  child: Text(
                    t.settings.logOut,
                    style: const TextStyle(fontSize: 20),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
