import 'package:auto_route/auto_route.dart';
import 'package:datn_mobile/core/router/router.gr.dart';
import 'package:auth_buttons/auth_buttons.dart';
import 'package:datn_mobile/features/auth/controllers/auth_controller_pod.dart';
import 'package:datn_mobile/features/auth/widgets/divider.dart';
import 'package:datn_mobile/features/auth/widgets/sign_in_form.dart';
import 'package:datn_mobile/features/auth/widgets/switch_page.dart';
import 'package:datn_mobile/shared/pods/translation_pod.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

@RoutePage()
class SignInPage extends StatefulWidget {
  const SignInPage({super.key});

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  void _navigateToSignUp() {
    context.router.replace(const SignUpRoute());
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      body: SafeArea(
        child: Consumer(
          builder: (context, ref, child) {
            final t = ref.watch(translationsPod);

            return SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 40),
                        // Logo or App Name
                        Icon(
                          LucideIcons.bookOpen,
                          size: 64,
                          color: colorScheme.primary,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          t.auth.signIn.welcome,
                          style: theme.textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onSurface,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          t.auth.signIn.subtitle,
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: colorScheme.onSurface.withAlpha(153),
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 40),

                        // SignInForm
                        const SignInForm(),
                        const SizedBox(height: 24),

                        // Divider + SignInForm + Google and Switch
                        const SignPageDivider(),
                        const SizedBox(height: 24),

                        // Google Sign In Button (kept separate to match SignUp layout)
                        Consumer(
                          builder:
                              (
                                BuildContext context,
                                WidgetRef ref,
                                Widget? child,
                              ) {
                                final authControllerNotifier = ref.read(
                                  authControllerProvider.notifier,
                                );

                                return GoogleAuthButton(
                                  onPressed: () async {
                                    await authControllerNotifier
                                        .signInWithGoogle();
                                  },
                                  style: const AuthButtonStyle(
                                    iconSize: 20.0,
                                    padding: EdgeInsets.symmetric(vertical: 16),
                                    textStyle: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  text: t.auth.signIn.googleSignInButton,
                                );
                              },
                        ),
                        const SizedBox(height: 24),

                        SwitchPageSection(
                          promptText: t.auth.signIn.noAccount,
                          actionText: t.auth.signIn.signUp,
                          onTap: _navigateToSignUp,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
