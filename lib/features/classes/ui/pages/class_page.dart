import 'package:auto_route/auto_route.dart';
import 'package:datn_mobile/core/router/router.gr.dart';
import 'package:datn_mobile/features/auth/controllers/user_controller.dart';
import 'package:datn_mobile/features/classes/domain/entity/class_entity.dart';
import 'package:datn_mobile/features/classes/states/controller_provider.dart';
import 'package:datn_mobile/features/classes/ui/widgets/app_drawer.dart';
import 'package:datn_mobile/features/classes/ui/widgets/class_action_fab.dart';
import 'package:datn_mobile/features/classes/ui/widgets/class_card.dart';
import 'package:datn_mobile/features/classes/ui/widgets/shared/create_class_dialog.dart';
import 'package:datn_mobile/shared/riverpod_ext/async_value_easy_when.dart';
import 'package:datn_mobile/shared/widgets/custom_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// Main page displaying the list of classes (Google Classroom style).
@RoutePage()
class ClassPage extends ConsumerWidget {
  const ClassPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final classesState = ref.watch(classesControllerProvider);
    final userState = ref.watch(userControllerProvider);
    final isStudent =
        userState.value != null; // If role has value, the user is student

    return Scaffold(
      appBar: const _ClassListAppBar(),
      drawer: const AppDrawer(),
      body: classesState.easyWhen(
        data: (classes) => _ClassListContent(
          classes: classes,
          isStudent: isStudent,
          onRefresh: () =>
              ref.read(classesControllerProvider.notifier).refresh(),
        ),
      ),
      // Uncomment if need
      floatingActionButton: isStudent
          ? null
          : ClassActionFab(
              onCreateClass: () => const CreateClassDialog().show(context, ref),
            ),
    );
  }

  // void _showJoinClassDialog(BuildContext context, WidgetRef ref) {
  //   final codeController = TextEditingController();
  //   final formKey = GlobalKey<FormState>();

  //   showDialog(
  //     context: context,
  //     builder: (dialogContext) => AlertDialog(
  //       title: const Text('Join Class'),
  //       content: Form(
  //         key: formKey,
  //         child: TextFormField(
  //           controller: codeController,
  //           decoration: const InputDecoration(
  //             labelText: 'Class code',
  //             hintText: 'Enter the code from your instructor',
  //           ),
  //           validator: (value) {
  //             if (value == null || value.isEmpty) {
  //               return 'Please enter a class code';
  //             }
  //             return null;
  //           },
  //           autofocus: true,
  //           textCapitalization: TextCapitalization.characters,
  //         ),
  //       ),
  //       actions: [
  //         TextButton(
  //           onPressed: () => Navigator.pop(dialogContext),
  //           child: const Text('Cancel'),
  //         ),
  //         FilledButton(
  //           onPressed: () async {
  //             if (formKey.currentState?.validate() ?? false) {
  //               Navigator.pop(dialogContext);
  //               await ref
  //                   .read(joinClassControllerProvider.notifier)
  //                   .joinClass(joinCode: codeController.text);
  //               if (context.mounted) {
  //                 ScaffoldMessenger.of(context).showSnackBar(
  //                   const SnackBar(content: Text('Joined class successfully')),
  //                 );
  //               }
  //             }
  //           },
  //           child: const Text('Join'),
  //         ),
  //       ],
  //     ),
  //   );
  // }
}

class _ClassListAppBar extends StatelessWidget implements PreferredSizeWidget {
  const _ClassListAppBar();

  @override
  Widget build(BuildContext context) {
    return const CustomAppBar(title: 'Classes');
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _ClassListContent extends StatelessWidget {
  final List<ClassEntity> classes;
  final bool isStudent;
  final Future<void> Function() onRefresh;

  const _ClassListContent({
    required this.classes,
    required this.isStudent,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    if (classes.isEmpty) {
      return const _EmptyState();
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
              onEdit: () {
                context.router.push(ClassEditRoute(classId: classEntity.id));
              },
              onDelete: () {
                _showDeleteConfirmation(context, classEntity);
              },
            );
          },
        ),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, ClassEntity classEntity) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Class'),
        content: Text('Are you sure you want to delete "${classEntity.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              // TODO: Implement delete class
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Delete not implemented yet')),
              );
            },
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Semantics(
      label: 'No classes yet. Create or join a class to get started.',
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ExcludeSemantics(
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer.withValues(alpha: 0.3),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    LucideIcons.graduationCap,
                    size: 64,
                    color: colorScheme.primary,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'No Classes Yet',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Create a new class or join an existing one\nusing a class code from your instructor.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              Consumer(
                builder: (context, ref, child) => Semantics(
                  label: 'Get started with classes',
                  button: true,
                  child: FilledButton.icon(
                    onPressed: () {
                      HapticFeedback.mediumImpact();
                      const CreateClassDialog().show(context, ref);
                    },
                    icon: const Icon(LucideIcons.plus),
                    label: const Text('Get Started'),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
