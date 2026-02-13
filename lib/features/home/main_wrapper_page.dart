import 'package:AIPrimary/features/classes/states/controller_provider.dart';
import 'package:AIPrimary/features/classes/ui/pages/class_detail_page.dart';
import 'package:AIPrimary/shared/pods/user_profile_pod.dart';
import 'package:auto_route/auto_route.dart';
import 'package:AIPrimary/core/router/router.gr.dart';
import 'package:AIPrimary/features/auth/domain/entities/user_role.dart';
import 'package:AIPrimary/shared/pods/translation_pod.dart';
import 'package:AIPrimary/shared/riverpod_ext/async_value_easy_when.dart';
import 'package:AIPrimary/shared/widgets/no_internet_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

@RoutePage()
class MainWrapperPage extends ConsumerWidget {
  const MainWrapperPage({super.key, this.title = 'Placeholder'});

  final String title;

  Widget _bottomItemActivated(
    IconData icon,
    String label,
    bool isActive,
    BuildContext context,
  ) {
    if (isActive) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(50),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 24,
              color: Theme.of(context).colorScheme.primary,
              fill: 0.5,
            ),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                label,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Icon(
      icon,
      size: 20,
      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userState = ref.watch(userControllerPod);
    final t = ref.watch(translationsPod);
    final isStudent = ref.watch(userRolePod) == UserRole.student;

    return userState.easyWhen(
      data: (userProfileState) {
        // For students, wait for classes to load before showing the UI
        if (isStudent) {
          final classesState = ref.watch(classesControllerProvider);

          // Show loading indicator while classes are being fetched
          if (classesState.isLoading ||
              !classesState.hasValue ||
              classesState.value!.isEmpty) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          final classId = classesState.value!.first.id;

          return ClassDetailPage(classId: classId);
        }

        // For teachers, show normal navigation
        return AutoTabsScaffold(
          routes: const [
            HomeRoute(),
            ProjectsRoute(),
            ClassRoute(),
            SettingRoute(),
          ],
          bottomNavigationBuilder: (_, tabsRouter) {
            if (userState.isLoading) {
              return const SizedBox.shrink();
            }

            return Theme(
              data: Theme.of(context).copyWith(
                splashColor: Colors.transparent,
                highlightColor: Colors.transparent,
              ),
              child: BottomNavigationBar(
                currentIndex: tabsRouter.activeIndex,
                onTap: tabsRouter.setActiveIndex,
                showSelectedLabels: false,
                showUnselectedLabels: false,
                type: BottomNavigationBarType.shifting,
                items: [
                  BottomNavigationBarItem(
                    icon: _bottomItemActivated(
                      LucideIcons.house,
                      t.navigation.home,
                      false,
                      context,
                    ),
                    activeIcon: _bottomItemActivated(
                      LucideIcons.house400,
                      t.navigation.home,
                      true,
                      context,
                    ),
                    label: "",
                  ),
                  BottomNavigationBarItem(
                    icon: _bottomItemActivated(
                      LucideIcons.folder,
                      t.navigation.project,
                      false,
                      context,
                    ),
                    activeIcon: _bottomItemActivated(
                      LucideIcons.folder,
                      t.navigation.project,
                      true,
                      context,
                    ),
                    label: "",
                  ),
                  BottomNavigationBarItem(
                    icon: _bottomItemActivated(
                      LucideIcons.school,
                      t.navigation.class_,
                      false,
                      context,
                    ),
                    activeIcon: _bottomItemActivated(
                      LucideIcons.school,
                      t.navigation.class_,
                      true,
                      context,
                    ),
                    label: "",
                  ),
                  BottomNavigationBarItem(
                    icon: _bottomItemActivated(
                      LucideIcons.user,
                      t.navigation.profile,
                      false,
                      context,
                    ),
                    activeIcon: _bottomItemActivated(
                      LucideIcons.user,
                      t.navigation.profile,
                      true,
                      context,
                    ),
                    label: "",
                  ),
                ],
              ),
            );
          },
        ).monitorConnection();
      },
    );
  }
}
