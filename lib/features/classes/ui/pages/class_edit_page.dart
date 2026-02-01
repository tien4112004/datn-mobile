import 'package:auto_route/auto_route.dart';
import 'package:AIPrimary/features/classes/domain/entity/class_entity.dart';
import 'package:AIPrimary/features/classes/states/controller_provider.dart';
import 'package:AIPrimary/features/classes/ui/widgets/edit/class_edit_form.dart';
import 'package:AIPrimary/shared/riverpod_ext/async_value_easy_when.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:AIPrimary/shared/pods/translation_pod.dart';

/// Comprehensive Class Edit Page for managing class information.
///
/// Features:
/// - Edit class name, description
/// - Toggle active status
/// - Material Design 3 styling
/// - Form validation
/// - Clean component architecture
@RoutePage()
class ClassEditPage extends ConsumerStatefulWidget {
  final String classId;

  const ClassEditPage({super.key, @PathParam('classId') required this.classId});

  @override
  ConsumerState<ClassEditPage> createState() => _ClassEditPageState();
}

class _ClassEditPageState extends ConsumerState<ClassEditPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late bool _isActive;
  bool _hasChanges = false;
  ClassEntity? _currentClass;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _descriptionController = TextEditingController();
    _isActive = true;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _initializeFields(ClassEntity classEntity) {
    if (_currentClass?.id != classEntity.id) {
      _currentClass = classEntity;
      _nameController.text = classEntity.name;
      _descriptionController.text = classEntity.description ?? '';
      _isActive = classEntity.isActive;
      _hasChanges = false;
    }
  }

  void _onFieldChanged() {
    if (!_hasChanges) {
      setState(() => _hasChanges = true);
    }
  }

  Future<void> _saveChanges() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final t = ref.read(translationsPod);
    final errorColor = Theme.of(context).colorScheme.error;

    await ref
        .read(updateClassControllerProvider.notifier)
        .updateClass(
          classId: widget.classId,
          name: _nameController.text.trim(),
          description: _descriptionController.text.trim().isEmpty
              ? null
              : _descriptionController.text.trim(),
          isActive: _isActive,
        );

    final updateState = ref.read(updateClassControllerProvider);

    updateState.whenOrNull(
      data: (_) {
        messenger.showSnackBar(
          SnackBar(
            content: Text(t.classes.editPage.saveSuccess),
            behavior: SnackBarBehavior.floating,
          ),
        );
        navigator.pop();
      },
      error: (error, _) {
        messenger.showSnackBar(
          SnackBar(
            content: Text(
              t.classes.editPage.saveError(error: error.toString()),
            ),
            behavior: SnackBarBehavior.floating,
            backgroundColor: errorColor,
          ),
        );
      },
    );
  }

  Future<bool> _onWillPop() async {
    if (!_hasChanges) return true;

    final t = ref.read(translationsPod);

    final shouldPop = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(t.classes.editPage.discardTitle),
        content: Text(t.classes.editPage.discardMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(t.classes.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: Text(t.classes.discard),
          ),
        ],
      ),
    );

    return shouldPop ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final classState = ref.watch(classesControllerProvider);
    final updateState = ref.watch(updateClassControllerProvider);
    final t = ref.watch(translationsPod);

    return PopScope(
      canPop: !_hasChanges,
      onPopInvokedWithResult: (didPop, result) async {
        if (!didPop && _hasChanges) {
          final shouldPop = await _onWillPop();
          if (shouldPop && context.mounted) {
            Navigator.of(context).pop();
          }
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(t.classes.editPage.title),
          centerTitle: false,
          leading: IconButton(
            icon: const Icon(LucideIcons.arrowLeft),
            onPressed: () async {
              final shouldPop = await _onWillPop();
              if (shouldPop && context.mounted) {
                Navigator.of(context).pop();
              }
            },
            tooltip: t.classes.back,
          ),
          actions: [
            // Save button
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: updateState.maybeWhen(
                loading: () => const Center(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
                ),
                orElse: () => FilledButton.icon(
                  onPressed: _hasChanges ? _saveChanges : null,
                  icon: const Icon(LucideIcons.save, size: 18),
                  label: Text(t.classes.save),
                ),
              ),
            ),
          ],
        ),
        body: classState.easyWhen(
          data: (classes) {
            final classEntity = classes.firstWhere(
              (c) => c.id == widget.classId,
              orElse: () => throw Exception('Class not found'),
            );

            _initializeFields(classEntity);

            return ClassEditForm(
              formKey: _formKey,
              classEntity: classEntity,
              nameController: _nameController,
              descriptionController: _descriptionController,
              isActive: _isActive,
              onFieldChanged: _onFieldChanged,
              onActiveChanged: (value) {
                setState(() {
                  _isActive = value;
                  _hasChanges = true;
                });
              },
            );
          },
        ),
      ),
    );
  }
}
