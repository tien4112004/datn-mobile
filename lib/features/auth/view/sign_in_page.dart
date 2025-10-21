import 'package:auto_route/auto_route.dart';
import 'package:datn_mobile/core/router/router.gr.dart';
import 'package:datn_mobile/features/auth/widgets/google_sign_in_button.dart';
import 'package:datn_mobile/features/auth/widgets/divider.dart';
import 'package:datn_mobile/features/auth/widgets/switch_page.dart';
import 'package:datn_mobile/features/auth/widgets/sign_in_form.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

@RoutePage()
class SignInPage extends StatefulWidget {
  const SignInPage({super.key});

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  void _handleGoogleSignIn() {
    // TODO: Implement Google Sign In logic
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Google Sign In button pressed')),
    );
  }

  void _navigateToSignUp() {
    context.router.push(const SignUpRoute());
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
                  const SizedBox(height: 40),
                  // Logo or App Name
                  Icon(
                    LucideIcons.bookOpen,
                    size: 64,
                    color: colorScheme.primary,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Welcome Back',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Sign in to continue',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: colorScheme.onSurface.withValues(alpha: 0.6),
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
                  GoogleSignInButton(onPressed: _handleGoogleSignIn),
                  const SizedBox(height: 24),

                  SwitchPageSection(
                    promptText: "Don't have an account? ",
                    actionText: 'Sign Up',
                    onTap: _navigateToSignUp,
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
