import 'package:datn_mobile/core/theme/app_theme.dart';
import 'package:datn_mobile/features/projects/states/controller_provider.dart';
import 'package:datn_mobile/features/projects/ui/widgets/common/recent_document_card.dart';
import 'package:datn_mobile/shared/pods/translation_pod.dart';
import 'package:datn_mobile/shared/riverpod_ext/async_value_easy_when.dart';
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
            data: (recentDocumentListState) => SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(vertical: Themes.padding.p16),
              child: recentDocumentListState.value.isEmpty
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
                      children: recentDocumentListState.value
                          .map(
                            (recentDocument) => Padding(
                              padding: EdgeInsets.only(
                                right: Themes.padding.p12,
                              ),
                              child: RecentDocumentCard(
                                recentDocument: recentDocument,
                              ),
                            ),
                          )
                          .toList(),
                    ),
            ),
          ),
        ),
      ],
    );
  }
}
