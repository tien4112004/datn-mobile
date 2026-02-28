import 'package:AIPrimary/shared/pods/translation_pod.dart';
import 'package:auto_route/auto_route.dart';
import 'package:AIPrimary/core/router/router.gr.dart';
import 'package:AIPrimary/features/assignments/data/dto/api/assignment_create_request.dart';
import 'package:AIPrimary/features/assignments/data/dto/api/assignment_update_request.dart';
import 'package:AIPrimary/features/assignments/domain/entity/assignment_entity.dart';
import 'package:AIPrimary/features/assignments/states/controller_provider.dart';
import 'package:AIPrimary/shared/models/cms_enums.dart';
import 'package:AIPrimary/shared/widgets/flex_dropdown_field.dart';
import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class AssignmentFormDialog extends ConsumerStatefulWidget {
  final AssignmentEntity? assignment;

  const AssignmentFormDialog({super.key, this.assignment});

  @override
  ConsumerState<AssignmentFormDialog> createState() =>
      _AssignmentFormDialogState();
}

class _AssignmentFormDialogState extends ConsumerState<AssignmentFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;

  Subject _selectedSubject = Subject.mathematics;
  GradeLevel _selectedGradeLevel = GradeLevel.grade1;

  bool get _isEditing => widget.assignment != null;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.assignment?.title);
    _descriptionController = TextEditingController(
      text: widget.assignment?.description,
    );
    if (widget.assignment != null) {
      _selectedSubject = widget.assignment!.subject;
      _selectedGradeLevel = widget.assignment!.gradeLevel;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = ref.watch(translationsPod);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Dialog(
      backgroundColor: colorScheme.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          _isEditing
                              ? t.assignments.form.editTitle
                              : t.assignments.form.createTitle,
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: colorScheme.onSurface,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(LucideIcons.x),
                        visualDensity: VisualDensity.compact,
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  TextFormField(
                    controller: _titleController,
                    decoration: InputDecoration(
                      labelText: t.assignments.form.titleLabel,
                      hintText: t.assignments.form.titleHint,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return t.assignments.form.titleRequired;
                      }
                      return null;
                    },
                    textCapitalization: TextCapitalization.words,
                  ),
                  const SizedBox(height: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 12, bottom: 8),
                        child: Text(
                          t.assignments.form.subjectLabel,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                      FlexDropdownField<Subject>(
                        value: _selectedSubject,
                        items: Subject.values,
                        itemLabelBuilder: (subject) =>
                            subject.getLocalizedName(t),
                        onChanged: (value) {
                          setState(() => _selectedSubject = value);
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 12, bottom: 8),
                        child: Text(
                          t.assignments.form.gradeLevelLabel,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                      FlexDropdownField<GradeLevel>(
                        value: _selectedGradeLevel,
                        items: GradeLevel.values,
                        itemLabelBuilder: (grade) => grade.getLocalizedName(t),
                        onChanged: (value) {
                          setState(() => _selectedGradeLevel = value);
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _descriptionController,
                    decoration: InputDecoration(
                      labelText: t.assignments.form.descriptionLabel,
                      hintText: t.assignments.form.descriptionHint,
                      alignLabelWithHint: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    maxLines: 3,
                    textCapitalization: TextCapitalization.sentences,
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text(t.assignments.form.cancel),
                      ),
                      const SizedBox(width: 8),
                      FilledButton.icon(
                        onPressed: _savedAssignment,
                        icon: Icon(
                          _isEditing ? LucideIcons.check : LucideIcons.plus,
                          size: 18,
                        ),
                        label: Text(
                          _isEditing
                              ? t.assignments.form.save
                              : t.assignments.form.create,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _savedAssignment() async {
    final t = ref.read(translationsPod);
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final title = _titleController.text.trim();
    final description = _descriptionController.text.trim();
    try {
      if (_isEditing) {
        final request = AssignmentUpdateRequest(
          title: title,
          description: description.isEmpty ? null : description,

          subject: _selectedSubject.apiValue,
          grade: _selectedGradeLevel.apiValue,
          questions: null, // Questions managed separately
        );

        await ref
            .read(updateAssignmentControllerProvider.notifier)
            .updateAssignment(widget.assignment!.assignmentId, request);

        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(t.assignments.form.updateSuccess)),
          );
        }
      } else {
        final request = AssignmentCreateRequest(
          title: title,
          description: description.isEmpty ? null : description,

          subject: _selectedSubject.apiValue,
          grade: _selectedGradeLevel.apiValue,
          questions: [], // Empty initially, add questions later
        );

        // Create assignment and get the created entity
        final createdAssignment = await ref
            .read(createAssignmentControllerProvider.notifier)
            .createAssignment(request);

        if (mounted) {
          // Close the dialog
          Navigator.pop(context);

          // Navigate to assignment detail page in edit mode
          if (!context.mounted) return;

          context.router.push(
            AssignmentDetailRoute(assignmentId: createdAssignment.assignmentId),
          );

          // Show success message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(t.assignments.form.createSuccess),
              duration: const Duration(seconds: 3),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        final t = ref.read(translationsPod);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(t.assignments.form.error(error: e.toString())),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }
}
