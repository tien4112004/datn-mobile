import 'package:auto_route/auto_route.dart';
import 'package:AIPrimary/core/router/router.gr.dart';
import 'package:AIPrimary/features/auth/controllers/user_controller.dart';
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
    final userState = ref.watch(userControllerProvider);
    final t = ref.watch(translationsPod);
    return userState.easyWhen(
      data: (userProfileState) {
        final isStudent = userState.value?.role == UserRole.student;
        final routes = isStudent
            ? [const ClassRoute(), const SettingRoute()]
            : [
                const HomeRoute(),
                const ProjectsRoute(),
                const ClassRoute(),
                const SettingRoute(),
              ];

        return AutoTabsScaffold(
          routes: routes,
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
                items: isStudent
                    ? [
                        BottomNavigationBarItem(
                          icon: _bottomItemActivated(
                            LucideIcons.school,
                            t.navigation.kClass,
                            false,
                            context,
                          ),
                          activeIcon: _bottomItemActivated(
                            LucideIcons.school,
                            t.navigation.kClass,
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
                      ]
                    : [
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
                            t.navigation.kClass,
                            false,
                            context,
                          ),
                          activeIcon: _bottomItemActivated(
                            LucideIcons.school,
                            t.navigation.kClass,
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
