import 'package:datn_mobile/features/students/data/dto/student_create_request_dto.dart';
import 'package:datn_mobile/features/students/data/dto/student_update_request_dto.dart';
import 'package:datn_mobile/features/students/domain/entity/student.dart';
import 'package:datn_mobile/features/students/enum/student_status.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// A form widget for creating or editing student information.
class StudentForm extends StatefulWidget {
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
  State<StudentForm> createState() => _StudentFormState();
}

class _StudentFormState extends State<StudentForm> {
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
  StudentStatus? _status;

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

    _enrollmentDate = student?.enrollmentDate;
    _status = student?.status;
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
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Student Information Section
            if (!widget.isEditMode) ...[
              const _SectionHeader(
                title: 'Student Information',
                icon: LucideIcons.user,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _fullNameController,
                decoration: const InputDecoration(
                  labelText: 'Full Name *',
                  hintText: 'Enter student\'s full name',
                  prefixIcon: Icon(LucideIcons.user),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Full name is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              _DatePickerField(
                label: 'Date of Birth',
                icon: LucideIcons.calendar,
                value: _dateOfBirth,
                onChanged: (date) => setState(() => _dateOfBirth = date),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _genderController,
                decoration: const InputDecoration(
                  labelText: 'Gender',
                  hintText: 'Enter gender',
                  prefixIcon: Icon(LucideIcons.users),
                ),
              ),
              const SizedBox(height: 24),

              // Parent Information Section
              const _SectionHeader(
                title: 'Parent Information',
                icon: LucideIcons.users,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _parentNameController,
                decoration: const InputDecoration(
                  labelText: 'Parent Name *',
                  hintText: 'Enter parent\'s name',
                  prefixIcon: Icon(LucideIcons.circleUser),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Parent name is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _parentPhoneController,
                decoration: const InputDecoration(
                  labelText: 'Parent Phone *',
                  hintText: 'Enter parent\'s phone number',
                  prefixIcon: Icon(LucideIcons.phone),
                ),
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Parent phone is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
            ],

            // Enrollment Information Section (both modes)
            const _SectionHeader(
              title: 'Enrollment Information',
              icon: LucideIcons.school,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _addressController,
              decoration: const InputDecoration(
                labelText: 'Address',
                hintText: 'Enter address',
                prefixIcon: Icon(LucideIcons.mapPin),
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _parentEmailController,
              decoration: const InputDecoration(
                labelText: 'Parent Contact Email',
                hintText: 'Enter parent\'s email',
                prefixIcon: Icon(LucideIcons.mail),
              ),
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value != null && value.isNotEmpty) {
                  final emailRegex = RegExp(
                    r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                  );
                  if (!emailRegex.hasMatch(value)) {
                    return 'Invalid email address';
                  }
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            _DatePickerField(
              label: 'Enrollment Date',
              icon: LucideIcons.calendarCheck,
              value: _enrollmentDate,
              onChanged: (date) => setState(() => _enrollmentDate = date),
            ),
            const SizedBox(height: 16),
            _StatusDropdown(
              value: _status,
              onChanged: (status) => setState(() => _status = status),
            ),
            const SizedBox(height: 32),

            // Submit button
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _onSubmit,
                icon: Icon(
                  widget.isEditMode ? LucideIcons.save : LucideIcons.userPlus,
                ),
                label: Text(
                  widget.isEditMode ? 'Save Changes' : 'Create Student',
                ),
              ),
            ),
          ],
        ),
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
        status: _status?.getValue(),
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
        status: _status?.getValue(),
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

class _DatePickerField extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: () async {
        final date = await showDatePicker(
          context: context,
          initialDate: value ?? DateTime.now(),
          firstDate: DateTime(1900),
          lastDate: DateTime.now().add(const Duration(days: 365)),
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
              : 'Select date',
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

class _StatusDropdown extends StatelessWidget {
  final StudentStatus? value;
  final ValueChanged<StudentStatus?> onChanged;

  const _StatusDropdown({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<StudentStatus>(
      initialValue: value,
      decoration: const InputDecoration(
        labelText: 'Status',
        prefixIcon: Icon(LucideIcons.activity),
      ),
      items: StudentStatus.values.map((status) {
        return DropdownMenuItem(
          value: status,
          child: Row(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: status.color,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(status.label[0].toUpperCase() + status.label.substring(1)),
            ],
          ),
        );
      }).toList(),
      onChanged: onChanged,
    );
  }
}
