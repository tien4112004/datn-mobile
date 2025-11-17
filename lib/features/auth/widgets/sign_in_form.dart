import 'package:auto_route/auto_route.dart';
import 'package:datn_mobile/core/router/router.gr.dart';
import 'package:datn_mobile/core/theme/app_theme.dart';
import 'package:datn_mobile/features/auth/controllers/auth_controller_pod.dart';
import 'package:datn_mobile/features/auth/controllers/auth_state.dart';
import 'package:datn_mobile/shared/helper/global_helper.dart';
import 'package:datn_mobile/shared/pods/translation_pod.dart';
import 'package:datn_mobile/shared/riverpod_ext/async_value_easy_when.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class SignInForm extends ConsumerStatefulWidget {
  const SignInForm({super.key});

  @override
  ConsumerState<SignInForm> createState() => _SignInFormState();
}

class _SignInFormState extends ConsumerState<SignInForm> with GlobalHelper {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _rememberMe = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleForgotPassword() {
    // TODO: Implement forgot password logic
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Forgot Password pressed')));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final t = ref.watch(translationsPod);
    final authController = ref.watch(authControllerProvider);
    final authControllerNotifier = ref.watch(authControllerProvider.notifier);

    ref.listen(authControllerProvider, (previous, next) {
      if (next is AsyncError) {
        final authState = next.error as AuthState;
        showErrorSnack(
          child: Text(authState.errorMessage ?? 'An unknown error occurred'),
        );
      }
    });

    return authController.easyWhen(
      data: (authState) {
        return Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Email Field
              TextFormField(
                enabled: !authState.isLoading,
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: t.auth.signIn.email,
                  hintText: t.auth.signIn.emailHint,
                  prefixIcon: const Icon(LucideIcons.mail),
                  border: const OutlineInputBorder(
                    borderRadius: Themes.boxRadius,
                  ),
                ),
                validator: (value) => _validateEmail(value),
              ),
              const SizedBox(height: 16),

              // Password Field
              TextFormField(
                enabled: !authState.isLoading,
                controller: _passwordController,
                obscureText: _obscurePassword,
                decoration: InputDecoration(
                  labelText: t.auth.signIn.password,
                  hintText: t.auth.signIn.passwordHint,
                  prefixIcon: const Icon(LucideIcons.lock),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword ? LucideIcons.eyeOff : LucideIcons.eye,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                  border: const OutlineInputBorder(
                    borderRadius: Themes.boxRadius,
                  ),
                ),
                validator: (value) => _validatePassword(value),
              ),
              const SizedBox(height: 12),

              // Remember Me & Forgot Password
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Checkbox(
                        value: _rememberMe,
                        onChanged: authState.isLoading
                            ? null
                            : (value) {
                                setState(() {
                                  _rememberMe = value ?? false;
                                });
                              },
                      ),
                      Text(
                        t.auth.signIn.rememberMe,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: authState.isLoading
                              ? colorScheme.primary.withAlpha(50)
                              : colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                  TextButton(
                    onPressed: authState.isLoading
                        ? null
                        : _handleForgotPassword,
                    child: Text(
                      t.auth.signIn.forgotPassword,
                      style: TextStyle(
                        color: authState.isLoading
                            ? colorScheme.primary.withAlpha(50)
                            : colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Sign In Button
              FilledButton(
                onPressed: () => {
                  if (_formKey.currentState!.validate())
                    {
                      if (authState.isLoading)
                        null
                      else if (authState.isAuthenticated)
                        context.router.replace(const HomeRoute())
                      else
                        authControllerNotifier.signIn(
                          _emailController.text,
                          _passwordController.text,
                        ),
                    },
                },
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: const RoundedRectangleBorder(
                    borderRadius: Themes.boxRadius,
                  ),
                ),
                child: authState.isLoading
                    ? const CircularProgressIndicator(
                        color: Colors.white,
                        constraints: BoxConstraints(
                          minWidth: 24.0,
                          minHeight: 24.0,
                        ),
                      )
                    : Text(
                        t.auth.signIn.signInButton,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ],
          ),
        );
      },
      skipError: true,
      skipLoadingOnReload: true,
    );
  }

  String? _validateEmail(String? value) {
    final t = ref.read(translationsPod);
    if (value == null || value.isEmpty) {
      return t.auth.signIn.validation.enterEmail;
    }
    if (!value.startsWith(
      RegExp(
        r'/^[a-z0-9]+(?!.*(?:\+{2,}|\-{2,}|\.{2,}))(?:[\.+\-]{0,1}[a-z0-9])*@gmail\.com$/gm',
      ),
    )) {
      return t.auth.signIn.validation.invalidEmail;
    }
    return null;
  }

  String? _validatePassword(String? value) {
    final t = ref.read(translationsPod);
    if (value == null || value.isEmpty) {
      return t.auth.signIn.validation.enterPassword;
    }
    if (value.length < 6) {
      return t.auth.signIn.validation.passwordMinLength;
    }
    return null;
  }
}
