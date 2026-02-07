import 'package:AIPrimary/features/auth/domain/entities/user_role.dart';
import 'package:AIPrimary/shared/pods/user_profile_pod.dart';
import 'package:auto_route/auto_route.dart';
import 'package:AIPrimary/features/classes/states/controller_provider.dart';
import 'package:AIPrimary/features/classes/ui/widgets/detail/class_detail_app_bar.dart';
import 'package:AIPrimary/features/classes/ui/widgets/detail/classwork_tab.dart';
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
    _tabController = TabController(length: 3, vsync: this);
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
          body: NestedScrollView(
            headerSliverBuilder: (context, innerBoxIsScrolled) {
              return [
                ClassDetailAppBar(
                  classEntity: classEntity,
                  isStudent: isStudent,
                ),
              ];
            },
            body: TabBarView(
              controller: _tabController,
              children: [
                StreamTab(classEntity: classEntity),
                ClassworkTab(classId: widget.classId),
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
                    text: t.classes.tabs.classwork,
                    icon: const Icon(LucideIcons.fileText, size: 20),
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
}
