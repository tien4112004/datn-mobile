import 'package:flutter/material.dart';

class SignPageDivider extends StatelessWidget {
  const SignPageDivider({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Row(
      children: [
        Expanded(child: Divider(color: colorScheme.outline)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'OR',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
        ),
        Expanded(child: Divider(color: colorScheme.outline)),
      ],
    );
  }
}
