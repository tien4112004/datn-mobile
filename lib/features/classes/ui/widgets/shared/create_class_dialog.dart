import 'package:datn_mobile/features/classes/states/controller_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CreateClassDialog {
  const CreateClassDialog({Key? key});

  Widget _build(BuildContext context, WidgetRef ref) {
    final nameController = TextEditingController();
    final descController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    return AlertDialog(
      title: const Text('Create Class'),
      content: Form(
        key: formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Class name',
                hintText: 'e.g., Advanced Software Development',
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a class name';
                }
                if (value.length > 50) {
                  return 'Name must be 50 characters or less';
                }
                return null;
              },
              autofocus: true,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: descController,
              decoration: const InputDecoration(
                labelText: 'Description (optional)',
                hintText: 'Brief class description',
              ),
              maxLines: 2,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () async {
            if (formKey.currentState?.validate() ?? false) {
              Navigator.pop(context);
              await ref
                  .read(createClassControllerProvider.notifier)
                  .createClass(
                    name: nameController.text,
                    description: descController.text.isEmpty
                        ? null
                        : descController.text,
                  );
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Class created successfully')),
                );
              }
            }
          },
          child: const Text('Create'),
        ),
      ],
    );
  }

  void show(BuildContext context, WidgetRef ref) {
    showDialog(context: context, builder: (context) => _build(context, ref));
  }
}
