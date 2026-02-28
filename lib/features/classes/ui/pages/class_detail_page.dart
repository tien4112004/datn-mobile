import 'package:AIPrimary/core/router/router.gr.dart';
import 'package:AIPrimary/features/auth/controllers/providers.dart';
import 'package:AIPrimary/features/auth/domain/entities/user_role.dart';
import 'package:AIPrimary/features/setting/widget/bottom_sheet/language_bottom_sheet.dart';
import 'package:AIPrimary/shared/pods/user_profile_pod.dart';
import 'package:auto_route/auto_route.dart';
import 'package:AIPrimary/features/classes/states/controller_provider.dart';
import 'package:AIPrimary/features/classes/ui/widgets/detail/class_detail_app_bar.dart';
import 'package:AIPrimary/features/classes/ui/widgets/detail/stream_tab.dart';
import 'package:AIPrimary/features/classes/ui/widgets/detail/students_tab.dart';
import 'package:AIPrimary/shared/riverpod_ext/async_value_easy_when.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:AIPrimary/shared/pods/translation_pod.dart';

/// Comprehensive Class Detail page with Stream, Classwork, and Students tabs.
/// Follows Material Design 3 guidelines with clean component separation.
@RoutePage()
class ClassDetailPage extends ConsumerStatefulWidget {
  final String classId;

  const ClassDetailPage({
    super.key,
    @PathParam('classId') required this.classId,
  });

  @override
  ConsumerState<ClassDetailPage> createState() => _ClassDetailPageState();
}

class _ClassDetailPageState extends ConsumerState<ClassDetailPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        HapticFeedback.selectionClick();
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final classState = ref.watch(detailClassControllerProvider(widget.classId));
    final t = ref.watch(translationsPod);
    final isStudent = ref.watch(userRolePod) == UserRole.student;

    return classState.easyWhen(
      data: (classEntity) {
        return Scaffold(
          drawer: isStudent
              ? _buildStudentDrawer(context, ref, t, classEntity)
              : null,
          body: NestedScrollView(
            headerSliverBuilder: (context, innerBoxIsScrolled) {
              return [
                ClassDetailAppBar(
                  classEntity: classEntity,
                  isStudent: isStudent,
                  onClassUpdated: () {
                    // Invalidate the provider to refetch updated class data
                    ref.invalidate(
                      detailClassControllerProvider(widget.classId),
                    );
                  },
                ),
              ];
            },
            body: TabBarView(
              controller: _tabController,
              children: [
                StreamTab(classEntity: classEntity),
                StudentsTab(classId: widget.classId),
              ],
            ),
          ),
          bottomNavigationBar: Container(
            color: Theme.of(context).colorScheme.surface,
            child: SafeArea(
              child: TabBar(
                controller: _tabController,
                indicatorColor: Theme.of(context).colorScheme.primary,
                labelColor: Theme.of(context).colorScheme.primary,
                unselectedLabelColor: Theme.of(
                  context,
                ).colorScheme.onSurfaceVariant,
                labelStyle: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
                unselectedLabelStyle: Theme.of(
                  context,
                ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.normal),
                tabs: [
                  Tab(
                    text: t.classes.tabs.stream,
                    icon: const Icon(LucideIcons.messageSquare, size: 20),
                    iconMargin: const EdgeInsets.only(bottom: 4),
                  ),
                  Tab(
                    text: t.classes.tabs.students,
                    icon: const Icon(LucideIcons.users, size: 20),
                    iconMargin: const EdgeInsets.only(bottom: 4),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  /// Builds the drawer for student users
  Widget _buildStudentDrawer(
    BuildContext context,
    WidgetRef ref,
    dynamic t,
    classEntity,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Drawer(
      child: SafeArea(
        top: false,
        child: Column(
          children: [
            // Drawer header with class info
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(24, 48, 24, 24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    classEntity.headerColor,
                    classEntity.headerColor.withValues(alpha: 0.85),
                  ],
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Class icon
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      LucideIcons.graduationCap,
                      size: 32,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Class name
                  Text(
                    classEntity.name,
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),

                  // Teacher name
                  Row(
                    children: [
                      const Icon(
                        LucideIcons.user,
                        size: 16,
                        color: Colors.white70,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          classEntity.teacherName,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: Colors.white70,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Menu items
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 8),
                children: [
                  // Notifications
                  ListTile(
                    leading: Icon(
                      LucideIcons.bell,
                      color: colorScheme.onSurface,
                    ),
                    title: Text(
                      t.notifications.title,
                      style: theme.textTheme.bodyLarge,
                    ),
                    onTap: () {
                      Navigator.pop(context); // Close drawer
                      context.router.push(const NotificationListRoute());
                    },
                  ),

                  const Divider(),

                  // Language settings
                  ListTile(
                    leading: Icon(
                      LucideIcons.languages,
                      color: colorScheme.onSurface,
                    ),
                    title: Text(
                      t.settings.language,
                      style: theme.textTheme.bodyLarge,
                    ),
                    onTap: () {
                      Navigator.pop(context); // Close drawer
                      showLanguageBottomSheet(context, ref);
                    },
                  ),

                  const Divider(),

                  // Logout
                  ListTile(
                    leading: Icon(LucideIcons.logOut, color: colorScheme.error),
                    title: Text(
                      t.settings.logOut,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: colorScheme.error,
                      ),
                    ),
                    onTap: () async {
                      Navigator.pop(context); // Close drawer

                      // Show confirmation dialog
                      final confirmed = await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: Text(t.settings.logOut),
                          content: Text(t.settings.logOutConfirmation),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: Text(t.classes.cancel),
                            ),
                            FilledButton(
                              onPressed: () => Navigator.pop(context, true),
                              style: FilledButton.styleFrom(
                                backgroundColor: colorScheme.error,
                              ),
                              child: Text(t.settings.logOut),
                            ),
                          ],
                        ),
                      );

                      if (confirmed == true && context.mounted) {
                        // Perform logout
                        await ref.read(authControllerPod.notifier).signOut();

                        if (context.mounted) {
                          // Navigate to sign-in page
                          context.router.replaceAll([const SignInRoute()]);
                        }
                      }
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
