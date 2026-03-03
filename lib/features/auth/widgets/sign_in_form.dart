import 'package:AIPrimary/core/theme/app_theme.dart';
import 'package:AIPrimary/features/auth/controllers/providers.dart';
import 'package:AIPrimary/shared/pods/translation_pod.dart';
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final t = ref.watch(translationsPod);
    final isLoading = ref.watch(authControllerPod).isLoading;
    final authControllerNotifier = ref.read(authControllerPod.notifier);

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Email Field
          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              labelText: t.auth.signIn.email,
              hintText: t.auth.signIn.emailHint,
              prefixIcon: const Icon(LucideIcons.mail),
              border: const OutlineInputBorder(borderRadius: Themes.boxRadius),
            ),
            validator: (value) => _validateNotBlank(value),
          ),
          const SizedBox(height: 16),

          // Password Field
          TextFormField(
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
              border: const OutlineInputBorder(borderRadius: Themes.boxRadius),
            ),
            validator: (value) => _validatePassword(value),
          ),
          const SizedBox(height: 12),

          // Remember Me
          Row(
            children: [
              Checkbox(
                value: _rememberMe,
                onChanged: (value) {
                  setState(() {
                    _rememberMe = value ?? false;
                  });
                },
              ),
              Text(
                t.auth.signIn.rememberMe,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Sign In Button
          FilledButton(
            onPressed: isLoading
                ? null
                : () => {
                    if (_formKey.currentState!.validate())
                      authControllerNotifier.signIn(
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
            child: isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator.adaptive(strokeWidth: 2),
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
  }

  String? _validateNotBlank(String? value) {
    final t = ref.read(translationsPod);
    if (value == null || value.isEmpty) {
      return t.auth.signIn.validation.enterEmail;
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
