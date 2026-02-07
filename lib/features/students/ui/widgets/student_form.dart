import 'package:AIPrimary/features/students/data/dto/student_create_request_dto.dart';
import 'package:AIPrimary/features/students/data/dto/student_update_request_dto.dart';
import 'package:AIPrimary/features/students/domain/entity/student.dart';
import 'package:AIPrimary/shared/helper/date_format_helper.dart';
import 'package:AIPrimary/shared/pods/translation_pod.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// A form widget for creating or editing student information.
class StudentForm extends ConsumerStatefulWidget {
  /// The class ID for the student (required for creation).
  final String classId;

  /// Initial student data for editing. Null for creation.
  final Student? initialStudent;

  /// Whether this form is in edit mode (limited fields).
  final bool isEditMode;

  /// Callback when form is submitted successfully.
  final void Function(StudentCreateRequestDto)? onCreateSubmit;
  final void Function(StudentUpdateRequestDto)? onUpdateSubmit;

  const StudentForm({
    super.key,
    required this.classId,
    this.initialStudent,
    this.isEditMode = false,
    this.onCreateSubmit,
    this.onUpdateSubmit,
  });

  @override
  ConsumerState<StudentForm> createState() => _StudentFormState();
}

class _StudentFormState extends ConsumerState<StudentForm> {
  final _formKey = GlobalKey<FormState>();

  // Controllers for create mode
  late TextEditingController _fullNameController;
  late TextEditingController _parentNameController;
  late TextEditingController _parentPhoneController;
  late TextEditingController _genderController;

  // Controllers for both modes
  late TextEditingController _addressController;
  late TextEditingController _parentEmailController;

  DateTime? _dateOfBirth;
  DateTime? _enrollmentDate;

  @override
  void initState() {
    super.initState();
    final student = widget.initialStudent;

    _fullNameController = TextEditingController(text: student?.fullName ?? '');
    _parentNameController = TextEditingController();
    _parentPhoneController = TextEditingController();
    _genderController = TextEditingController();
    _addressController = TextEditingController(text: student?.address ?? '');
    _parentEmailController = TextEditingController(
      text: student?.parentContactEmail ?? '',
    );
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _parentNameController.dispose();
    _parentPhoneController.dispose();
    _genderController.dispose();
    _addressController.dispose();
    _parentEmailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = ref.watch(translationsPod);

    return Form(
      key: _formKey,
      child: Column(
        children: [
          // Scrollable form content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Student Information Section
                  if (!widget.isEditMode) ...[
                    _SectionHeader(
                      title: t.students.info.studentInfo,
                      icon: LucideIcons.user,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _fullNameController,
                      decoration: InputDecoration(
                        labelText: t.students.info.fullName,
                        hintText: t.students.info.fullNameHint,
                        prefixIcon: const Icon(LucideIcons.user),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return t.students.info.fullNameRequired;
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    _DatePickerField(
                      label: t.students.info.dateOfBirth,
                      icon: LucideIcons.calendar,
                      value: _dateOfBirth,
                      onChanged: (date) => setState(() => _dateOfBirth = date),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _genderController,
                      decoration: InputDecoration(
                        labelText: t.students.info.gender,
                        hintText: t.students.info.genderHint,
                        prefixIcon: const Icon(LucideIcons.users),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Parent Information Section
                    _SectionHeader(
                      title: t.students.info.parentInfo,
                      icon: LucideIcons.users,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _parentNameController,
                      decoration: InputDecoration(
                        labelText: t.students.info.parentName,
                        hintText: t.students.info.parentNameHint,
                        prefixIcon: const Icon(LucideIcons.circleUser),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return t.students.info.parentNameRequired;
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _parentPhoneController,
                      decoration: InputDecoration(
                        labelText: t.students.info.parentPhone,
                        hintText: t.students.info.parentPhoneHint,
                        prefixIcon: const Icon(LucideIcons.phone),
                      ),
                      keyboardType: TextInputType.phone,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return t.students.info.parentPhoneRequired;
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Enrollment Information Section (both modes)
                  _SectionHeader(
                    title: t.students.info.enrollmentInfo,
                    icon: LucideIcons.school,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _addressController,
                    decoration: InputDecoration(
                      labelText: t.students.info.address,
                      hintText: t.students.info.addressHint,
                      prefixIcon: const Icon(LucideIcons.mapPin),
                    ),
                    maxLines: 2,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _parentEmailController,
                    decoration: InputDecoration(
                      labelText: t.students.info.parentEmail,
                      hintText: t.students.info.parentEmailHint,
                      prefixIcon: const Icon(LucideIcons.mail),
                    ),
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value != null && value.isNotEmpty) {
                        final emailRegex = RegExp(
                          r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                        );
                        if (!emailRegex.hasMatch(value)) {
                          return t.students.info.invalidEmail;
                        }
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  _DatePickerField(
                    label: t.students.info.enrollmentDate,
                    icon: LucideIcons.calendarCheck,
                    value: _enrollmentDate,
                    onChanged: (date) => setState(() => _enrollmentDate = date),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              height: 56,
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _onSubmit,
                icon: Icon(
                  widget.isEditMode ? LucideIcons.save : LucideIcons.userPlus,
                ),
                label: Text(
                  widget.isEditMode
                      ? t.students.saveChanges
                      : t.students.createStudent,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  void _onSubmit() {
    if (!_formKey.currentState!.validate()) return;

    if (widget.isEditMode) {
      final request = StudentUpdateRequestDto(
        enrollmentDate: _enrollmentDate,
        address: _addressController.text.isNotEmpty
            ? _addressController.text
            : null,
        parentContactEmail: _parentEmailController.text.isNotEmpty
            ? _parentEmailController.text
            : null,
      );
      widget.onUpdateSubmit?.call(request);
    } else {
      final request = StudentCreateRequestDto(
        fullName: _fullNameController.text.trim(),
        dateOfBirth: _dateOfBirth,
        gender: _genderController.text.isNotEmpty
            ? _genderController.text
            : null,
        address: _addressController.text.isNotEmpty
            ? _addressController.text
            : null,
        parentName: _parentNameController.text.trim(),
        parentPhone: _parentPhoneController.text.trim(),
        parentContactEmail: _parentEmailController.text.isNotEmpty
            ? _parentEmailController.text
            : null,
        classId: widget.classId,
        enrollmentDate: _enrollmentDate,
      );
      widget.onCreateSubmit?.call(request);
    }
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final IconData icon;

  const _SectionHeader({required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Icon(icon, size: 20, color: theme.colorScheme.primary),
        const SizedBox(width: 8),
        Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

class _DatePickerField extends ConsumerWidget {
  final String label;
  final IconData icon;
  final DateTime? value;
  final ValueChanged<DateTime?> onChanged;

  const _DatePickerField({
    required this.label,
    required this.icon,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(translationsPod);
    final theme = Theme.of(context);

    return InkWell(
      onTap: () async {
        final date = await showDatePicker(
          context: context,
          initialDate: value ?? DateFormatHelper.getNow(),
          firstDate: DateTime(1900),
          lastDate: DateFormatHelper.getNow().add(const Duration(days: 365)),
        );
        if (date != null) {
          onChanged(date);
        }
      },
      borderRadius: BorderRadius.circular(12),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          suffixIcon: const Icon(LucideIcons.chevronDown),
        ),
        child: Text(
          value != null
              ? '${value!.day.toString().padLeft(2, '0')}/${value!.month.toString().padLeft(2, '0')}/${value!.year}'
              : t.students.info.selectDate,
          style: TextStyle(
            color: value != null
                ? theme.colorScheme.onSurface
                : theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}
