import 'package:datn_mobile/core/theme/app_theme.dart';
import 'package:datn_mobile/features/auth/state/auth_controller_pod.dart';
import 'package:datn_mobile/shared/pods/translation_pod.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:datn_mobile/i18n/strings.g.dart';

class SignUpForm extends ConsumerStatefulWidget {
  const SignUpForm({super.key});

  @override
  ConsumerState<SignUpForm> createState() => _SignUpFormState();
}

class _SignUpFormState extends ConsumerState<SignUpForm> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _agreeToTerms = false;
  DateTime _selectedDate = DateTime.now();
  PhoneNumber _phoneNumber = PhoneNumber(isoCode: 'US');

  String? _termsErrorText;

  void _handleSignUp() {
    if (_formKey.currentState?.validate() ?? false) {
      if (!_agreeToTerms) {
        setState(() {
          _termsErrorText = t.auth.signUp.validation.agreeToTerms;
        });
        return;
      }

      ref
          .read(authControllerProvider.notifier)
          .signUp(
            firstName: _firstNameController.text,
            lastName: _lastNameController.text,
            email: _emailController.text,
            password: _passwordController.text,
            dateOfBirth: _selectedDate,
            phoneNumber: _phoneNumber.phoneNumber ?? '',
          );

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Sign Up button pressed')));
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Consumer(
      builder: (context, ref, child) {
        final t = ref.watch(translationsPod);

        return Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _firstNameController,
                      keyboardType: TextInputType.name,
                      decoration: InputDecoration(
                        labelText: t.auth.signUp.firstName,
                        hintText: t.auth.signUp.firstNameHint,
                        prefixIcon: const Icon(LucideIcons.user),
                        border: const OutlineInputBorder(
                          borderRadius: Themes.boxRadius,
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return t.auth.signUp.validation.enterName;
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _lastNameController,
                      keyboardType: TextInputType.name,
                      decoration: InputDecoration(
                        labelText: t.auth.signUp.lastName,
                        hintText: t.auth.signUp.lastNameHint,
                        prefixIcon: const Icon(LucideIcons.user),
                        border: const OutlineInputBorder(
                          borderRadius: Themes.boxRadius,
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return t.auth.signUp.validation.enterName;
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Email Field
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: t.auth.signUp.email,
                  hintText: t.auth.signUp.emailHint,
                  prefixIcon: const Icon(LucideIcons.mail),
                  border: const OutlineInputBorder(
                    borderRadius: Themes.boxRadius,
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return t.auth.signUp.validation.enterEmail;
                  }
                  if (!value.contains('@')) {
                    return t.auth.signUp.validation.invalidEmail;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Password Field
              TextFormField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                decoration: InputDecoration(
                  labelText: t.auth.signUp.password,
                  hintText: t.auth.signUp.passwordHint,
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
                    return t.auth.signUp.validation.enterPassword;
                  }
                  if (value.length < 6) {
                    return t.auth.signUp.validation.passwordMinLength;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Confirm Password Field
              TextFormField(
                controller: _confirmPasswordController,
                obscureText: _obscureConfirmPassword,
                decoration: InputDecoration(
                  labelText: t.auth.signUp.confirmPassword,
                  hintText: t.auth.signUp.confirmPasswordHint,
                  prefixIcon: const Icon(LucideIcons.lock),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureConfirmPassword
                          ? LucideIcons.eyeOff
                          : LucideIcons.eye,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscureConfirmPassword = !_obscureConfirmPassword;
                      });
                    },
                  ),
                  border: const OutlineInputBorder(
                    borderRadius: Themes.boxRadius,
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return t.auth.signUp.validation.confirmPassword;
                  }
                  if (value != _passwordController.text) {
                    return t.auth.signUp.validation.passwordsNotMatch;
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              TextFormField(
                readOnly: true, // Prevents manual keyboard input
                onTap: () => _selectDate(context),
                controller: TextEditingController(
                  // Format the date for display (requires `intl` package)
                  text: DateFormat('yyyy-MM-dd').format(_selectedDate),
                ),
                decoration: InputDecoration(
                  labelText: t.auth.signUp.dateOfBirth,
                  prefixIcon: const Icon(Icons.calendar_today),
                  border: const OutlineInputBorder(
                    borderRadius: Themes.boxRadius,
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return t.auth.signUp.validation.selectDateOfBirth;
                  }

                  if (_selectedDate.isAfter(DateTime.now())) {
                    return t.auth.signUp.validation.dateOfBirthFuture;
                  }

                  return null;
                },
              ),

              const SizedBox(height: 16),

              // Phone Number Field
              InternationalPhoneNumberInput(
                onInputChanged: (PhoneNumber number) {
                  setState(() {
                    _phoneNumber = number;
                  });
                },
                selectorConfig: const SelectorConfig(
                  selectorType: PhoneInputSelectorType.DROPDOWN,
                ),
                countries: ['US', 'VN', 'GB'],
                ignoreBlank: false,
                autoValidateMode: AutovalidateMode.onUserInteraction,
                selectorTextStyle: TextStyle(color: colorScheme.onSurface),
                formatInput: true,
                keyboardType: const TextInputType.numberWithOptions(
                  signed: true,
                  decimal: true,
                ),
                initialValue: PhoneNumber(isoCode: 'US'),
                inputBorder: const OutlineInputBorder(),
                inputDecoration: InputDecoration(
                  labelText: t.auth.signUp.phoneNumber,
                  hintText: t.auth.signUp.phoneNumberHint,
                  prefixIcon: const Icon(LucideIcons.phone),
                  border: const OutlineInputBorder(
                    borderRadius: Themes.boxRadius,
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return t.auth.signUp.validation.phoneNumberRequired;
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // Terms & Conditions
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: () {
                      // Toggle the checkbox when the row is tapped
                      setState(() {
                        _agreeToTerms = !_agreeToTerms;
                        _termsErrorText = null; // Clear error on interaction
                      });
                    },
                    child: Row(
                      children: [
                        Checkbox(
                          value: _agreeToTerms,
                          onChanged: (value) {
                            setState(() {
                              _agreeToTerms = value ?? false;
                              _termsErrorText = null; // Clear error on change
                            });
                          },
                        ),
                        Expanded(
                          child: Text.rich(
                            TextSpan(
                              text: t.auth.signUp.agreeToTerms,
                              style: theme.textTheme.bodyMedium,
                              children: [
                                TextSpan(
                                  text: t.auth.signUp.termsAndConditions,
                                  style: TextStyle(
                                    color: colorScheme.primary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Conditional Error Text below the checkbox row
                  if (_termsErrorText != null)
                    Padding(
                      // Add padding to indent the text slightly for visual alignment with input errors
                      padding: const EdgeInsets.only(left: 12.0, top: 0),
                      child: Text(
                        _termsErrorText!,
                        style: TextStyle(
                          color: colorScheme.error,
                          fontSize: theme.textTheme.bodySmall?.fontSize,
                        ),
                      ),
                    ),
                ],
              ),

              const SizedBox(height: 24),

              // Sign Up Button
              FilledButton(
                onPressed: _handleSignUp,
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: const RoundedRectangleBorder(
                    borderRadius: Themes.boxRadius,
                  ),
                ),
                child: Text(
                  t.auth.signUp.signUpButton,
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
