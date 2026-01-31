import 'package:AIPrimary/shared/pods/translation_pod.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// Section for editing basic class information.
///
/// Contains:
/// - Class name field (required, max 50 characters)
/// - Description field (optional, multiline)
///
/// Implements Material Design 3 text fields with:
/// - Clear labels and hints
/// - Character counters
/// - Validation feedback
/// - Accessible form design
class ClassInfoSection extends ConsumerWidget {
  final TextEditingController nameController;
  final TextEditingController descriptionController;
  final VoidCallback onFieldChanged;

  const ClassInfoSection({
    super.key,
    required this.nameController,
    required this.descriptionController,
    required this.onFieldChanged,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final t = ref.watch(translationsPod);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section header
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                LucideIcons.info,
                size: 20,
                color: colorScheme.onPrimaryContainer,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              t.classes.infoSection.title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),

        const SizedBox(height: 20),

        // Class name field
        Semantics(
          label: t.classes.infoSection.classNameLabel,
          child: TextFormField(
            controller: nameController,
            onChanged: (_) => onFieldChanged(),
            decoration: InputDecoration(
              labelText: t.classes.infoSection.classNameLabel,
              hintText: t.classes.infoSection.classNameHint,
              helperText: t.classes.infoSection.classNameHelper,
              prefixIcon: const Icon(LucideIcons.graduationCap),
              counterText: '${nameController.text.length}/50',
              border: const OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(12)),
              ),
            ),
            maxLength: 50,
            textCapitalization: TextCapitalization.words,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return t.classes.infoSection.classNameRequired;
              }
              if (value.trim().length < 3) {
                return t.classes.infoSection.classNameMinLength;
              }
              return null;
            },
            autovalidateMode: AutovalidateMode.onUserInteraction,
          ),
        ),

        const SizedBox(height: 20),

        // Description field
        Semantics(
          label: t.classes.infoSection.descriptionLabel,
          child: TextFormField(
            controller: descriptionController,
            onChanged: (_) => onFieldChanged(),
            decoration: InputDecoration(
              labelText: t.classes.infoSection.descriptionLabel,
              hintText: t.classes.infoSection.descriptionHint,
              helperText: t.classes.infoSection.descriptionHelper,
              prefixIcon: const Icon(LucideIcons.fileText),
              alignLabelWithHint: true,
              border: const OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(12)),
              ),
            ),
            maxLines: 4,
            minLines: 3,
            maxLength: 500,
            textCapitalization: TextCapitalization.sentences,
            keyboardType: TextInputType.multiline,
          ),
        ),
      ],
    );
  }
}
