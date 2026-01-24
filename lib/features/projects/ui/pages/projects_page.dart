import 'package:auto_route/auto_route.dart';
import 'package:datn_mobile/core/router/router.gr.dart';
import 'package:datn_mobile/core/theme/app_theme.dart';
import 'package:datn_mobile/features/projects/enum/resource_type.dart';
import 'package:datn_mobile/features/projects/ui/widgets/common/recent_documents_row.dart';
import 'package:datn_mobile/features/projects/ui/widgets/resource/resource_types_list.dart';
import 'package:datn_mobile/shared/pods/translation_pod.dart';
import 'package:datn_mobile/shared/widgets/custom_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

@RoutePage()
class ProjectsPage extends ConsumerWidget {
  const ProjectsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(translationsPod);

    return Scaffold(
      appBar: CustomAppBar(title: t.projects.title),
      body: const _ProjectsView(),
      floatingActionButton: Container(
        width: 64,
        height: 64,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            colors: [Colors.blue.shade400, Colors.pink.shade300],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: FloatingActionButton(
          onPressed: () {
            context.router.push(const GenerateRoute());
          },
          backgroundColor: Colors.transparent,
          elevation: 0,
          shape: const CircleBorder(),
          highlightElevation: 0,
          child: const Icon(
            LucideIcons.sparkles,
            color: Colors.white,
            size: 32,
          ),
        ),
      ),
    );
  }
}

class _ProjectsView extends ConsumerStatefulWidget {
  const _ProjectsView();

  @override
  ConsumerState<_ProjectsView> createState() => _ProjectsViewState();
}

class _ProjectsViewState extends ConsumerState<_ProjectsView> {
  void _onResourceTypeSelected(ResourceType resourceType) {
    switch (resourceType) {
      case ResourceType.presentation:
        context.router.push(const PresentationListRoute());
      case ResourceType.mindmap:
        context.router.push(const MindmapListRoute());
      case ResourceType.image:
        context.router.push(const ImageListRoute());
      case ResourceType.question:
        context.router.push(const QuestionBankRoute());
      case ResourceType.assignment:
        context.router.push(const AssignmentsRoute());
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = ref.watch(translationsPod);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RecentDocumentsRow(title: t.projects.recently_works),
          Text(
            t.projects.categories,
            textAlign: TextAlign.start,
            style: TextStyle(
              fontSize: Themes.fontSize.s24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: SingleChildScrollView(
              child: ResourceTypesList(
                onResourceTypeSelected: _onResourceTypeSelected,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
