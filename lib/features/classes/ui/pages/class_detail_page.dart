import 'package:auto_route/auto_route.dart';
import 'package:datn_mobile/features/classes/domain/entity/class_entity.dart';
import 'package:datn_mobile/features/classes/states/controller_provider.dart';
import 'package:datn_mobile/features/classes/ui/widgets/detail/classwork_tab.dart';
import 'package:datn_mobile/features/classes/ui/widgets/detail/stream_tab.dart';
import 'package:datn_mobile/features/classes/ui/widgets/detail/students_tab.dart';
import 'package:datn_mobile/shared/riverpod_ext/async_value_easy_when.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

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
    final classState = ref.watch(classesControllerProvider);

    return classState.easyWhen(
      data: (classes) {
        // Find the specific class by ID
        final classEntity = classes.firstWhere(
          (c) => c.id == widget.classId,
          orElse: () => ClassEntity(
            id: widget.classId,
            ownerId: '',
            name: 'Class',
            isActive: true,
          ),
        );

        return Scaffold(
          body: NestedScrollView(
            headerSliverBuilder: (context, innerBoxIsScrolled) {
              return [_ClassDetailAppBar(classEntity: classEntity)];
            },
            body: TabBarView(
              controller: _tabController,
              children: [
                StreamTab(classId: widget.classId),
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
                tabs: const [
                  Tab(
                    text: 'STREAM',
                    icon: Icon(LucideIcons.messageSquare, size: 20),
                    iconMargin: EdgeInsets.only(bottom: 4),
                  ),
                  Tab(
                    text: 'CLASSWORK',
                    icon: Icon(LucideIcons.fileText, size: 20),
                    iconMargin: EdgeInsets.only(bottom: 4),
                  ),
                  Tab(
                    text: 'STUDENTS',
                    icon: Icon(LucideIcons.users, size: 20),
                    iconMargin: EdgeInsets.only(bottom: 4),
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

/// Sliver app bar with class header and tab navigation.
class _ClassDetailAppBar extends StatelessWidget {
  final ClassEntity classEntity;

  const _ClassDetailAppBar({required this.classEntity});

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 200,
      floating: false,
      pinned: true,
      elevation: 0,
      backgroundColor: classEntity.headerColor,
      foregroundColor: Colors.white,
      systemOverlayStyle: SystemUiOverlayStyle.light,
      leading: Semantics(
        label: 'Go back',
        button: true,
        hint: 'Double tap to return to classes list',
        child: IconButton(
          icon: const Icon(LucideIcons.arrowLeft),
          onPressed: () {
            HapticFeedback.lightImpact();
            context.router.maybePop();
          },
          tooltip: 'Back',
        ),
      ),
      actions: [
        Semantics(
          label: 'Class options',
          button: true,
          hint: 'Double tap to see more options',
          child: IconButton(
            icon: const Icon(LucideIcons.ellipsisVertical),
            onPressed: () {
              HapticFeedback.mediumImpact();
              _showClassOptions(context);
            },
            tooltip: 'More options',
          ),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          classEntity.name,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        expandedTitleScale: 1.4,
        titlePadding: const EdgeInsets.only(top: 16, bottom: 16),
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                classEntity.headerColor,
                classEntity.headerColor.withValues(alpha: 0.85),
              ],
            ),
          ),
          child: Stack(
            children: [
              // Decorative pattern
              Positioned(
                right: -20,
                top: -20,
                child: Container(
                  width: 150,
                  height: 150,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              Positioned(
                left: -30,
                bottom: 0,
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.08),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              // Class info overlay
              Positioned(
                bottom: 60,
                left: 16,
                right: 16,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (classEntity.description != null &&
                        classEntity.description!.isNotEmpty)
                      Text(
                        classEntity.description!,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          height: 1.4,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(
                          LucideIcons.user,
                          size: 16,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          classEntity.displayInstructorName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showClassOptions(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(LucideIcons.info, color: colorScheme.primary),
              title: const Text('Class Information'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Show class information dialog
              },
            ),
            ListTile(
              leading: Icon(LucideIcons.copy, color: colorScheme.primary),
              title: const Text('Copy Join Code'),
              subtitle: Text(classEntity.joinCode ?? 'Not available'),
              onTap: () {
                Navigator.pop(context);
                if (classEntity.joinCode != null) {
                  Clipboard.setData(ClipboardData(text: classEntity.joinCode!));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Join code copied')),
                  );
                }
              },
            ),
            ListTile(
              leading: Icon(LucideIcons.settings, color: colorScheme.primary),
              title: const Text('Class Settings'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Navigate to class settings
              },
            ),
          ],
        ),
      ),
    );
  }
}
