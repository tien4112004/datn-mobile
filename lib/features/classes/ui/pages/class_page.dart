import 'package:AIPrimary/shared/pods/user_profile_pod.dart';
import 'package:auto_route/auto_route.dart';
import 'package:AIPrimary/core/router/router.gr.dart';
import 'package:AIPrimary/features/auth/domain/entities/user_role.dart';
import 'package:AIPrimary/features/classes/domain/entity/class_entity.dart';
import 'package:AIPrimary/features/classes/states/controller_provider.dart';
import 'package:AIPrimary/features/classes/ui/widgets/class_action_fab.dart';
import 'package:AIPrimary/features/classes/ui/widgets/class_card.dart';
import 'package:AIPrimary/features/classes/ui/widgets/shared/create_class_dialog.dart';
import 'package:AIPrimary/shared/riverpod_ext/async_value_easy_when.dart';
import 'package:AIPrimary/shared/widgets/custom_app_bar.dart';
import 'package:AIPrimary/shared/widgets/enhanced_empty_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:AIPrimary/shared/pods/translation_pod.dart';

/// Main page displaying the list of classes (Google Classroom style).
@RoutePage()
class ClassPage extends ConsumerStatefulWidget {
  const ClassPage({super.key});

  @override
  ConsumerState<ClassPage> createState() => _ClassPageState();
}

class _ClassPageState extends ConsumerState<ClassPage> {
  bool _didAutoRedirect = false;

  @override
  Widget build(BuildContext context) {
    final classesState = ref.watch(classesControllerProvider);
    final isStudent = ref.watch(userRolePod) == UserRole.student;

    classesState.whenData((classes) {
      if (isStudent && !_didAutoRedirect && classes.isNotEmpty) {
        _didAutoRedirect = true;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            context.router.push(ClassDetailRoute(classId: classes[0].id));
          }
        });
      }
    });

    return Scaffold(
      appBar: const _ClassListAppBar(),
      body: classesState.easyWhen(
        data: (classes) => _ClassListContent(
          classes: classes,
          isStudent: isStudent,
          onRefresh: () =>
              ref.read(classesControllerProvider.notifier).refresh(),
        ),
      ),
      floatingActionButton: isStudent
          ? null
          : ClassActionFab(
              onCreateClass: () => const CreateClassDialog().show(context, ref),
            ),
    );
  }
}

class _ClassListAppBar extends ConsumerWidget implements PreferredSizeWidget {
  const _ClassListAppBar();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(translationsPod);
    return CustomAppBar(title: t.classes.title);
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _ClassListContent extends ConsumerWidget {
  final List<ClassEntity> classes;
  final bool isStudent;
  final Future<void> Function() onRefresh;

  const _ClassListContent({
    required this.classes,
    required this.isStudent,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(translationsPod);

    if (classes.isEmpty) {
      return EnhancedEmptyState(
        icon: LucideIcons.graduationCap,
        title: t.classes.emptyState.noClasses,
        message: t.classes.emptyState.noClassesDescription,
        actionLabel: isStudent ? null : t.classes.emptyState.getStarted,
        onAction: isStudent
            ? null
            : () {
                HapticFeedback.mediumImpact();
                const CreateClassDialog().show(context, ref);
              },
        semanticLabel: t.classes.emptyState.semanticLabel,
      );
    }

    return Semantics(
      label: '${classes.length} classes',
      child: RefreshIndicator(
        onRefresh: onRefresh,
        child: ListView.builder(
          padding: const EdgeInsets.only(top: 8, bottom: 88),
          itemCount: classes.length,
          itemBuilder: (context, index) {
            final classEntity = classes[index];
            return ClassCard(
              key: ValueKey(classEntity.id),
              classEntity: classEntity,
              onTap: () {
                context.router.push(ClassDetailRoute(classId: classEntity.id));
              },
              onViewStudents: () {
                context.router.push(StudentListRoute(classId: classEntity.id));
              },
              onEdit: isStudent
                  ? null
                  : () {
                      context.router.push(
                        ClassEditRoute(classId: classEntity.id),
                      );
                    },
              onDelete: isStudent
                  ? null
                  : () {
                      _showDeleteConfirmation(context, classEntity, t);
                    },
            );
          },
        ),
      ),
    );
  }

  void _showDeleteConfirmation(
    BuildContext context,
    ClassEntity classEntity,
    dynamic t,
  ) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(t.classes.deleteDialog.title),
        content: Text(
          t.classes.deleteDialog.message(className: classEntity.name),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(t.classes.cancel),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              // TODO: Implement delete class
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(t.classes.deleteDialog.notImplemented)),
              );
            },
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: Text(t.classes.delete),
          ),
        ],
      ),
    );
  }
}
