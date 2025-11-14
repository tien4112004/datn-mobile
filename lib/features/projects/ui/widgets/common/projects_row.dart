import 'package:datn_mobile/core/theme/app_theme.dart';
import 'package:datn_mobile/features/projects/states/controller_provider.dart';
import 'package:datn_mobile/features/projects/ui/widgets/presentation/presentation_card.dart';
import 'package:datn_mobile/shared/riverpod_ext/async_value_easy_when.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ProjectsRow extends ConsumerWidget {
  const ProjectsRow({this.title, super.key, required this.onProjectSelected});

  final Function(String) onProjectSelected;
  final String? title;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final presentationsAsync = ref.watch(presentationsControllerProvider);

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
          constraints: const BoxConstraints(minHeight: 160, maxHeight: 220),
          child: presentationsAsync.easyWhen(
            data: (presentationListState) => SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(vertical: Themes.padding.p16),
              child: Row(
                children: presentationListState.value
                    .map(
                      (presentation) => Padding(
                        padding: EdgeInsets.only(right: Themes.padding.p12),
                        child: PresentationCard(presentation: presentation),
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
