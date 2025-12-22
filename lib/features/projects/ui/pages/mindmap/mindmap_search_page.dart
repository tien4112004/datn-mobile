import 'package:auto_route/auto_route.dart';
import 'package:datn_mobile/features/projects/domain/entity/mindmap_minimal.dart';
import 'package:datn_mobile/features/projects/states/controller_provider.dart';
import 'package:datn_mobile/features/projects/ui/pages/common/generic_search_page.dart';
import 'package:datn_mobile/shared/helper/date_format_helper.dart';
import 'package:datn_mobile/shared/pods/translation_pod.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

@RoutePage()
class MindmapSearchPage extends ConsumerWidget {
  const MindmapSearchPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(translationsPod);

    return GenericResourceSearchPage<MindmapMinimal>(
      title: t.projects.mindmaps.search_mindmaps,
      resourceAsyncProvider: mindmapsControllerProvider,
      searchPredicate: (mindmap, query) {
        return mindmap.title.toLowerCase().contains(query.toLowerCase());
      },
      itemBuilder: (context, mindmap, onTap) {
        return ListTile(
          leading: const Icon(LucideIcons.map),
          title: Text(mindmap.title),
          subtitle: Text(
            mindmap.createdAt != null
                ? t.projects.created_at(
                    date: DateFormatHelper.formatRelativeDate(
                      mindmap.createdAt!,
                      ref: ref,
                    ),
                  )
                : t.projects.unknown_date,
          ),
          trailing: const Icon(LucideIcons.chevronRight, size: 18),
          onTap: onTap,
        );
      },
      emptyStateMessage: t.projects.no_mindmaps,
      noResultsMessage: 'No results found',
    );
  }
}
