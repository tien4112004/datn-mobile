import 'package:auto_route/auto_route.dart';
import 'package:datn_mobile/core/router/router.gr.dart';
import 'package:datn_mobile/features/auth/controllers/auth_controller_pod.dart';
import 'package:datn_mobile/features/auth/widgets/divider.dart';
import 'package:auth_buttons/auth_buttons.dart';
import 'package:datn_mobile/features/auth/widgets/sign_up_form.dart';
import 'package:datn_mobile/features/auth/widgets/switch_page.dart';
import 'package:datn_mobile/shared/exception/base_exception.dart';
import 'package:datn_mobile/shared/helper/global_helper.dart';
import 'package:datn_mobile/shared/pods/loading_overlay_pod.dart';
import 'package:datn_mobile/shared/pods/translation_pod.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

@RoutePage()
class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> with GlobalHelper {
  void _navigateToSignIn() {
    context.router.replace(const SignInRoute());
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Consumer(
      builder: (context, ref, child) {
        final t = ref.watch(translationsPod);

        ref.listen(authControllerPod, (previous, next) {
          next.when(
            data: (state) {
              ref.watch(loadingOverlayPod.notifier).state = false;
              if (state.isSignedUp) {
                // Navigate to the verification page
                context.router.replace(const SignInRoute());
              }
            },
            loading: () {
              ref.watch(loadingOverlayPod.notifier).state = true;
            },
            error: (error, stackTrace) {
              ref.watch(loadingOverlayPod.notifier).state = false;
              final exception = next.error as APIException;
              showErrorSnack(child: Text(exception.errorMessage));
            },
          );
        });

        return Scaffold(
          body: SafeArea(
            child: Center(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Logo or App Name
                      Icon(
                        LucideIcons.bookOpen,
                        size: 64,
                        color: colorScheme.primary,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        t.auth.signUp.title,
                        style: theme.textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurface,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        t.auth.signUp.subtitle,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: colorScheme.onSurface.withAlpha(153),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 32),

                      const SignUpForm(),
                      const SizedBox(height: 24),

                      // Divider
                      const SignPageDivider(),
                      const SizedBox(height: 24),

                      // Google Sign In Button
                      GoogleAuthButton(
                        onPressed: () async {
                          await ref
                              .watch(authControllerPod.notifier)
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
                        text: t.auth.signUp.googleSignInButton,
                      ),
                      const SizedBox(height: 24),

                      SwitchPageSection(
                        promptText: t.auth.signUp.haveAccount,
                        actionText: t.auth.signUp.signIn,
                        onTap: _navigateToSignIn,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
