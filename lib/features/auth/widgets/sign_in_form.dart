import 'package:datn_mobile/core/theme/app_theme.dart';
import 'package:datn_mobile/features/auth/state/auth_controller_pod.dart';
import 'package:datn_mobile/shared/pods/translation_pod.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class SignInForm extends ConsumerStatefulWidget {
  const SignInForm({super.key});

  @override
  ConsumerState<SignInForm> createState() => _SignInFormState();
}

class _SignInFormState extends ConsumerState<SignInForm> {
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
    final signinControllerPod = ref.watch(authControllerProvider);
    final signinController = ref.watch(authControllerProvider.notifier);

    return Consumer(
      builder: (context, ref, child) {
        return Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Email Field
              TextFormField(
                enabled: !signinControllerPod.isLoading,
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
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return t.auth.signIn.validation.enterEmail;
                  }
                  if (!value.contains('@')) {
                    return t.auth.signIn.validation.invalidEmail;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Password Field
              TextFormField(
                enabled: !signinControllerPod.isLoading,
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
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return t.auth.signIn.validation.enterPassword;
                  }
                  if (value.length < 6) {
                    return t.auth.signIn.validation.passwordMinLength;
                  }
                  return null;
                },
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
                        onChanged: signinControllerPod.isLoading
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
                          color: signinControllerPod.isLoading
                              ? colorScheme.primary.withAlpha(50)
                              : colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                  TextButton(
                    onPressed: signinControllerPod.isLoading
                        ? null
                        : _handleForgotPassword,
                    child: Text(
                      t.auth.signIn.forgotPassword,
                      style: TextStyle(
                        color: signinControllerPod.isLoading
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
                  signinController.signIn(
                    _emailController.text,
                    _passwordController.text,
                  ),
                },
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: const RoundedRectangleBorder(
                    borderRadius: Themes.boxRadius,
                  ),
                ),
                child: signinControllerPod.isLoading
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
    );
  }
}
