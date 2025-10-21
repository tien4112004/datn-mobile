import 'package:auto_route/auto_route.dart';
import 'package:datn_mobile/features/auth/widgets/divider.dart';
import 'package:datn_mobile/features/auth/widgets/google_sign_in_button.dart';
import 'package:datn_mobile/features/auth/widgets/sign_up_form.dart';
import 'package:datn_mobile/features/auth/widgets/switch_page.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

@RoutePage()
class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  void _handleGoogleSignUp() {
    // TODO: Implement Google Sign In logic
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Google Sign In button pressed')),
    );
  }

  void _navigateToSignIn() {
    context.router.maybePop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
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
                    'Create Account',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Sign up to get started',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: colorScheme.onSurface.withValues(alpha: 0.6),
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
                  GoogleSignInButton(onPressed: _handleGoogleSignUp),
                  const SizedBox(height: 24),

                  SwitchPageSection(
                    promptText: 'Already have an account? ',
                    actionText: 'Sign In',
                    onTap: _navigateToSignIn,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
