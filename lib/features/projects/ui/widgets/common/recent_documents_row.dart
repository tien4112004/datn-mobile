import 'package:AIPrimary/core/theme/app_theme.dart';
import 'package:AIPrimary/features/projects/states/controller_provider.dart';
import 'package:AIPrimary/features/projects/ui/widgets/common/recent_document_card.dart';
import 'package:AIPrimary/shared/pods/translation_pod.dart';
import 'package:AIPrimary/features/projects/ui/widgets/common/project_loading_skeleton.dart';
import 'package:AIPrimary/shared/riverpod_ext/async_value_easy_when.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class RecentDocumentsRow extends ConsumerWidget {
  const RecentDocumentsRow({this.title, super.key});

  final String? title;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recentDocumentsAsync = ref.watch(recentDocumentsControllerProvider);
    final t = ref.watch(translationsPod);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title != null)
          Text(
            title!,
            style: TextStyle(
              fontSize: Themes.fontSize.s24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 160),
          child: recentDocumentsAsync.easyWhen(
            data: (resouce) => SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(vertical: Themes.padding.p16),
              child: resouce.value.isEmpty
                  ? Center(
                      child: Text(
                        t.projects.no_recent_works,
                        style: TextStyle(
                          fontSize: Themes.fontSize.s20,
                          color: Colors.grey,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    )
                  : Row(
                      children: List.generate(
                        resouce.value.length,
                        (index) => Padding(
                          padding: EdgeInsets.only(right: Themes.padding.p12),
                          child: RecentDocumentCard(
                            recentDocument: resouce.value[index],
                          ),
                        ),
                      ),
                    ),
            ),
            loadingWidget: () => SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(vertical: Themes.padding.p16),
              child: Row(
                children: List.generate(
                  3,
                  (index) => Padding(
                    padding: EdgeInsets.only(right: Themes.padding.p12),
                    child: const SizedBox(
                      width: 160,
                      height: 180,
                      child: ProjectGridSkeletonCard(),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
