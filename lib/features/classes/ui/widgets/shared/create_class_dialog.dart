import 'package:AIPrimary/features/classes/states/controller_provider.dart';
import 'package:AIPrimary/shared/pods/translation_pod.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CreateClassDialog {
  const CreateClassDialog({Key? key});

  Widget _build(BuildContext context, WidgetRef ref) {
    final nameController = TextEditingController();
    final descController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    final t = ref.read(translationsPod);

    return AlertDialog(
      title: Text(t.classes.createDialog.title),
      content: Form(
        key: formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: t.classes.createDialog.classNameLabel,
                hintText: t.classes.createDialog.classNameHint,
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return t.classes.createDialog.classNameRequired;
                }
                if (value.length > 50) {
                  return t.classes.createDialog.classNameMaxLength;
                }
                return null;
              },
              autofocus: true,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: descController,
              decoration: InputDecoration(
                labelText: t.classes.createDialog.descriptionLabel,
                hintText: t.classes.createDialog.descriptionHint,
              ),
              maxLines: 2,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(t.classes.cancel),
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
                  SnackBar(content: Text(t.classes.createDialog.createSuccess)),
                );
              }
            }
          },
          child: Text(t.classes.create),
        ),
      ],
    );
  }

  void show(BuildContext context, WidgetRef ref) {
    showDialog(context: context, builder: (context) => _build(context, ref));
  }
}
