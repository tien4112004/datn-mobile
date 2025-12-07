import 'package:auto_route/auto_route.dart';
import 'package:datn_mobile/const/app_urls.dart';
import 'package:datn_mobile/core/router/router.gr.dart';
import 'package:datn_mobile/core/theme/app_theme.dart';
import 'package:datn_mobile/features/projects/ui/widgets/common/projects_row.dart';
import 'package:datn_mobile/features/projects/ui/widgets/resource/resource_types_list.dart';
import 'package:datn_mobile/shared/pods/translation_pod.dart';
import 'package:datn_mobile/shared/widget/app_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

@RoutePage()
class ProjectsPage extends ConsumerWidget {
  const ProjectsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(translationsPod);

    return Scaffold(
      appBar: AppAppBar(title: t.projects.title),
      body: const _ProjectsView(),
      floatingActionButton: SizedBox(
        width: 96,
        height: 96,
        child: FloatingActionButton(
          onPressed: () {
            context.router.push(const PresentationGenerateRoute());
          },
          backgroundColor: Colors.transparent,
          elevation: 0,
          shape: const CircleBorder(),
          splashColor: Colors.transparent,
          hoverColor: Colors.transparent,
          focusColor: Colors.transparent,
          highlightElevation: 0,
          child: ClipOval(
            child: Image.asset(
              AppUrls.floatingButtonImg,
              width: 96,
              height: 96,
              fit: BoxFit.cover,
            ),
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
  void _onResourceTypeSelected(String resourceType) {
    context.router.push(ResourceListRoute(resourceType: resourceType));
  }

  void _onProjectSelected(String projectId) {
    // context.router.push(ProjectDetailRoute(projectId: projectId));
  }

  @override
  Widget build(BuildContext context) {
    final t = ref.watch(translationsPod);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ProjectsRow(
            onProjectSelected: _onProjectSelected,
            title: t.projects.recently_works,
          ),
          Text(
            t.projects.type_of_resources,
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
