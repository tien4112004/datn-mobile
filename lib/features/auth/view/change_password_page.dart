import 'package:auto_route/auto_route.dart';
import 'package:AIPrimary/core/router/router.gr.dart';
import 'package:AIPrimary/core/theme/app_theme.dart';
import 'package:AIPrimary/shared/api_client/dio/dio_client_provider.dart';
import 'package:AIPrimary/shared/helper/global_helper.dart';
import 'package:AIPrimary/shared/pods/translation_pod.dart';
import 'package:AIPrimary/shared/widgets/custom_app_bar.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

@RoutePage()
class ChangePasswordPage extends ConsumerStatefulWidget {
  const ChangePasswordPage({super.key, this.isForced = false});

  final bool isForced;

  @override
  ConsumerState<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends ConsumerState<ChangePasswordPage>
    with GlobalHelper {
  final _formKey = GlobalKey<FormState>();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscureCurrent = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final dio = ref.read(dioPod);
      final response = await dio.post(
        '/user/change-password',
        data: {
          'currentPassword': _currentPasswordController.text,
          'newPassword': _newPasswordController.text,
        },
      );

      final body = response.data as Map<String, dynamic>;
      if (body['success'] != true) {
        showErrorSnack(
          child: Text(body['message'] ?? 'Failed to change password'),
        );
        return;
      }

      if (!mounted) return;
      final t = ref.read(translationsPod);
      showSuccessSnack(child: Text(t.changePassword.success));

      if (widget.isForced) {
        context.router.replaceAll([const HomeRoute()]);
      } else {
        context.router.maybePop();
      }
    } on DioException catch (e) {
      final body = e.response?.data as Map<String, dynamic>?;
      showErrorSnack(
        child: Text(body?['message'] ?? 'Invalid current password'),
      );
    } catch (_) {
      showErrorSnack(child: const Text('An unexpected error occurred'));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = ref.watch(translationsPod);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return PopScope(
      canPop: !widget.isForced,
      child: Scaffold(
        appBar: widget.isForced
            ? null
            : CustomAppBar(title: t.changePassword.title),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (widget.isForced) ...[
                    const SizedBox(height: 40),
                    Icon(
                      LucideIcons.lockKeyhole,
                      size: 64,
                      color: colorScheme.primary,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      t.changePassword.title,
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                  ],

                  // Temporary password notice
                  if (widget.isForced)
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: colorScheme.primaryContainer,
                        borderRadius: Themes.boxRadius,
                      ),
                      child: Row(
                        children: [
                          Icon(
                            LucideIcons.info,
                            size: 18,
                            color: colorScheme.onPrimaryContainer,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              t.changePassword.tempPasswordNotice,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: colorScheme.onPrimaryContainer,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                  const SizedBox(height: 24),

                  // Current Password
                  TextFormField(
                    controller: _currentPasswordController,
                    obscureText: _obscureCurrent,
                    decoration: InputDecoration(
                      labelText: t.changePassword.currentPassword,
                      hintText: t.changePassword.currentPasswordHint,
                      prefixIcon: const Icon(LucideIcons.lock),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureCurrent
                              ? LucideIcons.eyeOff
                              : LucideIcons.eye,
                        ),
                        onPressed: () =>
                            setState(() => _obscureCurrent = !_obscureCurrent),
                      ),
                      border: const OutlineInputBorder(
                        borderRadius: Themes.boxRadius,
                      ),
                    ),
                    validator: (v) {
                      if (v == null || v.isEmpty) {
                        return t.changePassword.validation.enterCurrentPassword;
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // New Password
                  TextFormField(
                    controller: _newPasswordController,
                    obscureText: _obscureNew,
                    decoration: InputDecoration(
                      labelText: t.changePassword.newPassword,
                      hintText: t.changePassword.newPasswordHint,
                      prefixIcon: const Icon(LucideIcons.lockKeyhole),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureNew ? LucideIcons.eyeOff : LucideIcons.eye,
                        ),
                        onPressed: () =>
                            setState(() => _obscureNew = !_obscureNew),
                      ),
                      border: const OutlineInputBorder(
                        borderRadius: Themes.boxRadius,
                      ),
                    ),
                    validator: (v) {
                      if (v == null || v.isEmpty) {
                        return t.changePassword.validation.enterNewPassword;
                      }
                      if (v.length < 6) {
                        return t.changePassword.validation.passwordMinLength;
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Confirm New Password
                  TextFormField(
                    controller: _confirmPasswordController,
                    obscureText: _obscureConfirm,
                    decoration: InputDecoration(
                      labelText: t.changePassword.confirmPassword,
                      hintText: t.changePassword.confirmPasswordHint,
                      prefixIcon: const Icon(LucideIcons.lockKeyhole),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureConfirm
                              ? LucideIcons.eyeOff
                              : LucideIcons.eye,
                        ),
                        onPressed: () =>
                            setState(() => _obscureConfirm = !_obscureConfirm),
                      ),
                      border: const OutlineInputBorder(
                        borderRadius: Themes.boxRadius,
                      ),
                    ),
                    validator: (v) {
                      if (v == null || v.isEmpty) {
                        return t.changePassword.validation.confirmPassword;
                      }
                      if (v != _newPasswordController.text) {
                        return t.changePassword.validation.passwordsNotMatch;
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),

                  const SizedBox(height: 12),

                  // Submit Button
                  FilledButton(
                    onPressed: _isLoading ? null : _submit,
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: const RoundedRectangleBorder(
                        borderRadius: Themes.boxRadius,
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(
                            t.changePassword.submit,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
