import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// Floating Action Button for class actions.
///
/// Creates a new class when tapped.
class ClassActionFab extends ConsumerWidget {
  final VoidCallback onCreateClass;

  const ClassActionFab({super.key, required this.onCreateClass});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;

    return FloatingActionButton(
      onPressed: () => onCreateClass(),
      backgroundColor: colorScheme.primary,
      foregroundColor: colorScheme.onPrimary,
      child: const Icon(LucideIcons.plus),
    );
  }
}
