import 'package:datn_mobile/core/theme/app_theme.dart';
import 'package:flutter/material.dart';

/// A custom Google Sign In button widget
/// This widget provides a UI-only implementation for Google Sign In
class GoogleSignInButton extends StatelessWidget {
  /// Callback function when the button is pressed
  final VoidCallback onPressed;

  const GoogleSignInButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16),
        side: BorderSide(color: colorScheme.outline),
        shape: const RoundedRectangleBorder(borderRadius: Themes.boxRadius),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Google Logo (Using a placeholder - in production, use an actual Google logo asset)
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Center(
              child: Image.asset(
                "assets/google_logo.png",
                width: 18,
                height: 18,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            'Continue with Google',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}
