import 'package:flutter/material.dart';
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
class ClassInfoSection extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

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
              'Class Information',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),

        const SizedBox(height: 20),

        // Class name field
        Semantics(
          label: 'Class name input field, required',
          child: TextFormField(
            controller: nameController,
            onChanged: (_) => onFieldChanged(),
            decoration: InputDecoration(
              labelText: 'Class Name *',
              hintText: 'Enter class name',
              helperText: 'Required field, maximum 50 characters',
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
                return 'Please enter a class name';
              }
              if (value.trim().length < 3) {
                return 'Class name must be at least 3 characters';
              }
              return null;
            },
            autovalidateMode: AutovalidateMode.onUserInteraction,
          ),
        ),

        const SizedBox(height: 20),

        // Description field
        Semantics(
          label: 'Class description input field, optional',
          child: TextFormField(
            controller: descriptionController,
            onChanged: (_) => onFieldChanged(),
            decoration: const InputDecoration(
              labelText: 'Description',
              hintText: 'Enter class description (optional)',
              helperText: 'Add details about this class',
              prefixIcon: Icon(LucideIcons.fileText),
              alignLabelWithHint: true,
              border: OutlineInputBorder(
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
