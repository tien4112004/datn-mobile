import 'package:AIPrimary/features/assignments/ui/widgets/detail/floating_action_menu.dart';
import 'package:AIPrimary/features/classes/states/controller_provider.dart'
    as class_provider;
import 'package:AIPrimary/features/students/domain/entity/student_credential.dart';
import 'package:AIPrimary/features/students/domain/entity/student_import_result.dart';
import 'package:AIPrimary/shared/pods/user_profile_pod.dart';
import 'package:auto_route/auto_route.dart';
import 'package:AIPrimary/core/router/router.gr.dart';
import 'package:AIPrimary/features/auth/domain/entities/user_role.dart';
import 'package:AIPrimary/features/students/states/controller_provider.dart';
import 'package:AIPrimary/features/students/ui/widgets/student_tile.dart';
import 'package:AIPrimary/shared/pods/translation_pod.dart';
import 'package:AIPrimary/shared/riverpod_ext/async_value_easy_when.dart';
import 'package:AIPrimary/shared/service/student_csv_service.dart';
import 'package:AIPrimary/shared/services/service_pod.dart';
import 'package:AIPrimary/shared/widgets/enhanced_empty_state.dart';
import 'package:AIPrimary/shared/widgets/enhanced_count_header.dart';
import 'package:AIPrimary/shared/widgets/animated_list_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// Students tab showing all students in the class.
class StudentsTab extends ConsumerWidget {
  final String classId;

  const StudentsTab({super.key, required this.classId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final studentsState = ref.watch(studentsControllerProvider(classId));
    final t = ref.watch(translationsPod);
    final userRole = ref.watch(userRolePod);
    final isStudent = userRole == UserRole.student;

    final csvService = StudentCsvService(ref.read(downloadServiceProvider));

    // Resolve the class name for export filenames (falls back to classId).
    final className =
        ref
            .watch(class_provider.detailClassControllerProvider(classId))
            .value
            ?.name ??
        classId;

    return Scaffold(
      body: studentsState.easyWhen(
        data: (listState) => RefreshIndicator(
          onRefresh: () =>
              ref.read(studentsControllerProvider(classId).notifier).refresh(),
          child: _StudentsContent(
            classId: classId,
            students: listState.value,
            t: t,
            onExportCsv: isStudent
                ? null
                : () => _showExportSheet(
                    context,
                    ref,
                    listState.value,
                    t,
                    csvService,
                    className,
                  ),
          ),
        ),
        onRetry: () =>
            ref.read(studentsControllerProvider(classId).notifier).refresh(),
      ),
      floatingActionButton: isStudent
          ? null
          : FloatingActionMenu(
              mainIcon: LucideIcons.userPlus,
              mainLabel: t.classes.students.addStudent,
              items: [
                FloatingActionMenuItem(
                  label: t.classes.students.addManually,
                  icon: LucideIcons.userPlus,
                  onTap: () {
                    HapticFeedback.mediumImpact();
                    context.router.push(StudentCreateRoute(classId: classId));
                  },
                ),
                FloatingActionMenuItem(
                  label: t.classes.students.fromFile,
                  icon: LucideIcons.fileUp,
                  onTap: () {
                    HapticFeedback.lightImpact();
                    _showFileActionsSheet(context, ref, t, csvService);
                  },
                ),
              ],
            ),
    );
  }

  // ── File actions sheet (import + download template) ──────────────────────

  void _showFileActionsSheet(
    BuildContext context,
    WidgetRef ref,
    dynamic t,
    StudentCsvService csvService,
  ) {
    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _sheetHandle(context),
              _sheetTitle(context, t.classes.students.fileActions),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(LucideIcons.upload),
                title: Text(t.classes.students.importFromCsv),
                subtitle: Text(t.classes.students.importHint),
                onTap: () {
                  Navigator.of(sheetContext).pop();
                  _handleImportCsv(context, ref, t, csvService);
                },
              ),
              ListTile(
                leading: const Icon(LucideIcons.fileDown),
                title: Text(t.classes.students.downloadTemplate),
                subtitle: Text(t.classes.students.downloadTemplateHint),
                onTap: () {
                  Navigator.of(sheetContext).pop();
                  _handleDownloadTemplate(context, t, csvService);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Export sheet (download to device + share) ────────────────────────────

  void _showExportSheet(
    BuildContext context,
    WidgetRef ref,
    List students,
    dynamic t,
    StudentCsvService csvService,
    String className,
  ) {
    if (students.isEmpty) return;

    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _sheetHandle(context),
              _sheetTitle(context, t.classes.students.exportOptions),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(LucideIcons.hardDriveDownload),
                title: Text(t.classes.students.downloadToDevice),
                subtitle: Text(t.classes.students.downloadToDeviceHint),
                onTap: () {
                  Navigator.of(sheetContext).pop();
                  _handleExportToDevice(
                    context,
                    students,
                    t,
                    csvService,
                    className,
                  );
                },
              ),
              ListTile(
                leading: const Icon(LucideIcons.share2),
                title: Text(t.classes.students.shareFile),
                subtitle: Text(t.classes.students.shareFileHint),
                onTap: () {
                  Navigator.of(sheetContext).pop();
                  _handleShareCsv(
                    context,
                    ref,
                    students,
                    t,
                    csvService,
                    className,
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Handlers ─────────────────────────────────────────────────────────────

  Future<void> _handleImportCsv(
    BuildContext context,
    WidgetRef ref,
    dynamic t,
    StudentCsvService csvService,
  ) async {
    final file = await csvService.pickCsvFile();
    if (file == null) return;
    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            const SizedBox(width: 16),
            Text(t.classes.students.importing),
          ],
        ),
        duration: const Duration(seconds: 30),
      ),
    );

    try {
      final result = await ref
          .read(importStudentsControllerProvider.notifier)
          .importFromCsv(classId: classId, file: file);

      if (!context.mounted) return;
      ScaffoldMessenger.of(context).clearSnackBars();
      await _showImportResultDialog(context, result, t);
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(t.classes.students.importFailed(error: e.toString())),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  Future<void> _handleExportToDevice(
    BuildContext context,
    List students,
    dynamic t,
    StudentCsvService csvService,
    String className,
  ) async {
    try {
      final savedPath = await csvService.exportStudentsToCsv(
        students.cast(),
        fileName: _buildExportFileName(className),
      );
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(t.classes.students.exportSaved(path: savedPath)),
          backgroundColor: Theme.of(context).colorScheme.primary,
          duration: const Duration(seconds: 4),
        ),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(t.classes.students.exportFailed(error: e.toString())),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  Future<void> _handleShareCsv(
    BuildContext context,
    WidgetRef ref,
    List students,
    dynamic t,
    StudentCsvService csvService,
    String className,
  ) async {
    try {
      final exportFileName = _buildExportFileName(className);
      final tempPath = await csvService.exportStudentsToCsvTemp(
        students.cast(),
        fileName: exportFileName,
      );
      await ref
          .read(shareServiceProvider)
          .shareFile(filePath: tempPath, subject: exportFileName);
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(t.classes.students.exportFailed(error: e.toString())),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  Future<void> _handleDownloadTemplate(
    BuildContext context,
    dynamic t,
    StudentCsvService csvService,
  ) async {
    try {
      final savedPath = await csvService.saveTemplate();
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(t.classes.students.templateSaved(path: savedPath)),
          backgroundColor: Theme.of(context).colorScheme.primary,
          duration: const Duration(seconds: 4),
        ),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(t.classes.students.templateFailed(error: e.toString())),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  /// Builds a filename in the format `class_<className>_<yyyyMMdd_HHmmss>.csv`.
  /// Sanitises the class name by replacing whitespace/special chars with `_`.
  String _buildExportFileName(String className) {
    final sanitised = className
        .trim()
        .replaceAll(RegExp(r'[^\w\u00C0-\u024F]+'), '_')
        .replaceAll(RegExp(r'_+'), '_')
        .toLowerCase();
    final now = DateTime.now();
    final ts =
        '${now.year}${_pad(now.month)}${_pad(now.day)}_${_pad(now.hour)}${_pad(now.minute)}${_pad(now.second)}';
    return 'class_${sanitised}_$ts.csv';
  }

  String _pad(int n) => n.toString().padLeft(2, '0');

  Future<void> _showImportResultDialog(
    BuildContext context,
    StudentImportResult result,
    dynamic t,
  ) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => _ImportResultDialog(result: result, t: t),
    );
  }

  // ── Shared sheet widgets ──────────────────────────────────────────────────

  Widget _sheetHandle(BuildContext context) => Container(
    width: 36,
    height: 4,
    margin: const EdgeInsets.only(bottom: 12),
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.outlineVariant,
      borderRadius: BorderRadius.circular(2),
    ),
  );

  Widget _sheetTitle(BuildContext context, String title) => Padding(
    padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
    child: Text(
      title,
      style: Theme.of(
        context,
      ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
    ),
  );
}

// ── Content ───────────────────────────────────────────────────────────────────

class _StudentsContent extends ConsumerWidget {
  final String classId;
  final List students;
  final dynamic t;
  final VoidCallback? onExportCsv;

  const _StudentsContent({
    required this.classId,
    required this.students,
    required this.t,
    this.onExportCsv,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (students.isEmpty) {
      return EnhancedEmptyState(
        icon: LucideIcons.userPlus,
        title: t.classes.students.emptyTitle,
        message: t.classes.students.emptyDescription,
        actionLabel: t.classes.students.addFirstStudent,
        onAction: () {
          context.router.push(StudentCreateRoute(classId: classId));
        },
      );
    }

    final isStudent = ref.watch(userRolePod) == UserRole.student;
    final currentUserId = ref.watch(userIdPod);

    final sortedStudents = List.from(students);
    if (isStudent) {
      sortedStudents.sort((a, b) {
        if (a.userId == currentUserId) return -1;
        if (b.userId == currentUserId) return 1;
        return 0;
      });
    }

    return Column(
      children: [
        EnhancedCountHeader(
          icon: LucideIcons.users,
          title: t.classes.students.classRoster,
          count: students.length,
          countLabel: t.classes.students.student,
          onExportCsv: onExportCsv,
        ),
        Expanded(
          child: Semantics(
            label: t.classes.students.studentCount(count: students.length),
            child: ListView.builder(
              padding: const EdgeInsets.only(top: 8, bottom: 80),
              itemCount: sortedStudents.length,
              itemBuilder: (context, index) {
                final student = sortedStudents[index];
                return AnimatedListItem(
                  index: index,
                  child: StudentTile(
                    key: ValueKey(student.id),
                    student: student,
                    onTap: () {
                      context.router.push(
                        StudentDetailRoute(studentId: student.id),
                      );
                    },
                    isCurrentStudent:
                        isStudent && student.userId == ref.watch(userIdPod),
                    onEdit: isStudent
                        ? null
                        : () {
                            context.router.push(
                              StudentEditRoute(
                                classId: classId,
                                studentId: student.id,
                              ),
                            );
                          },
                    onDelete: isStudent
                        ? null
                        : () => _showDeleteDialog(context, ref, student),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  void _showDeleteDialog(BuildContext context, WidgetRef ref, dynamic student) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(t.classes.students.removeTitle),
        content: Text(
          t.classes.students.removeMessage(studentName: student.fullName),
          semanticsLabel: t.classes.students.removeSemanticLabel(
            studentName: student.fullName,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(t.classes.cancel),
          ),
          FilledButton(
            onPressed: () async {
              HapticFeedback.heavyImpact();
              Navigator.of(dialogContext).pop();

              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Row(
                      children: [
                        const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                        const SizedBox(width: 16),
                        Text(t.classes.students.removing),
                      ],
                    ),
                    duration: const Duration(seconds: 2),
                  ),
                );
              }

              try {
                await ref
                    .read(removeStudentControllerProvider.notifier)
                    .remove(classId: classId, studentId: student.id);

                if (context.mounted) {
                  ScaffoldMessenger.of(context).clearSnackBars();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        t.classes.students.removeSuccess(
                          studentName: student.fullName,
                        ),
                      ),
                      backgroundColor: Theme.of(context).colorScheme.primary,
                    ),
                  );
                  ref
                      .read(studentsControllerProvider(classId).notifier)
                      .refresh();
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).clearSnackBars();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        t.classes.students.removeError(error: e.toString()),
                      ),
                      backgroundColor: Theme.of(context).colorScheme.error,
                    ),
                  );
                }
              }
            },
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: Text(t.classes.students.remove),
          ),
        ],
      ),
    );
  }
}

// ── Import result dialog ──────────────────────────────────────────────────────

class _ImportResultDialog extends StatefulWidget {
  final StudentImportResult result;
  final dynamic t;

  const _ImportResultDialog({required this.result, required this.t});

  @override
  State<_ImportResultDialog> createState() => _ImportResultDialogState();
}

class _ImportResultDialogState extends State<_ImportResultDialog> {
  final Map<String, bool> _passwordVisibility = {};

  void _copyToClipboard(String text, String label) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$label copied to clipboard'),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final t = widget.t;
    final result = widget.result;

    return AlertDialog(
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: result.success
                  ? colorScheme.primaryContainer
                  : colorScheme.errorContainer,
              shape: BoxShape.circle,
            ),
            child: Icon(
              result.success ? LucideIcons.circleCheck : LucideIcons.circleX,
              color: result.success ? colorScheme.primary : colorScheme.error,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              t.classes.students.importResultTitle,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      content: SizedBox(
        width: double.maxFinite,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Summary
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: result.studentsCreated > 0
                      ? colorScheme.primaryContainer
                      : colorScheme.errorContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  t.classes.students.importResultMessage(
                    count: result.studentsCreated,
                  ),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: result.studentsCreated > 0
                        ? colorScheme.onPrimaryContainer
                        : colorScheme.onErrorContainer,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),

              // Errors
              if (result.errors.isNotEmpty) ...[
                const SizedBox(height: 16),
                Text(
                  t.classes.students.importResultErrors,
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: colorScheme.error,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                ...result.errors.map(
                  (error) => Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          LucideIcons.circleAlert,
                          size: 14,
                          color: colorScheme.error,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            error,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: colorScheme.error,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],

              // Credentials
              if (result.credentials.isNotEmpty) ...[
                const SizedBox(height: 16),
                Text(
                  t.classes.students.importResultCredentials,
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                ...result.credentials.map(
                  (cred) => _CredentialCard(
                    credential: cred,
                    isPasswordVisible:
                        _passwordVisibility[cred.studentId] ?? false,
                    onToggleVisibility: () => setState(() {
                      _passwordVisibility[cred.studentId] =
                          !(_passwordVisibility[cred.studentId] ?? false);
                    }),
                    onCopyUsername: () =>
                        _copyToClipboard(cred.username, 'Username'),
                    onCopyPassword: () =>
                        _copyToClipboard(cred.password, 'Password'),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
      actions: [
        FilledButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Done'),
        ),
      ],
    );
  }
}

class _CredentialCard extends StatelessWidget {
  final StudentCredential credential;
  final bool isPasswordVisible;
  final VoidCallback onToggleVisibility;
  final VoidCallback onCopyUsername;
  final VoidCallback onCopyPassword;

  const _CredentialCard({
    required this.credential,
    required this.isPasswordVisible,
    required this.onToggleVisibility,
    required this.onCopyUsername,
    required this.onCopyPassword,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            credential.fullName,
            style: theme.textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(LucideIcons.user, size: 14, color: colorScheme.primary),
              const SizedBox(width: 6),
              Expanded(
                child: SelectableText(
                  credential.username,
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontFamily: 'monospace',
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(LucideIcons.copy, size: 16),
                onPressed: onCopyUsername,
                tooltip: 'Copy username',
                visualDensity: VisualDensity.compact,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
              ),
            ],
          ),
          Row(
            children: [
              Icon(LucideIcons.lock, size: 14, color: colorScheme.primary),
              const SizedBox(width: 6),
              Expanded(
                child: SelectableText(
                  isPasswordVisible ? credential.password : '••••••••',
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontFamily: 'monospace',
                  ),
                ),
              ),
              IconButton(
                icon: Icon(
                  isPasswordVisible ? LucideIcons.eyeOff : LucideIcons.eye,
                  size: 16,
                ),
                onPressed: onToggleVisibility,
                tooltip: isPasswordVisible ? 'Hide' : 'Show',
                visualDensity: VisualDensity.compact,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
              ),
              IconButton(
                icon: const Icon(LucideIcons.copy, size: 16),
                onPressed: onCopyPassword,
                tooltip: 'Copy password',
                visualDensity: VisualDensity.compact,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
