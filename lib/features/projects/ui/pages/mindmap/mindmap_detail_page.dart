import 'package:auto_route/auto_route.dart';
import 'package:AIPrimary/features/projects/states/controller_provider.dart';
import 'package:AIPrimary/features/projects/ui/widgets/mindmap/mindmap_detail.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

@RoutePage()
class MindmapDetailPage extends ConsumerWidget {
  final String mindmapId;
  const MindmapDetailPage({
    super.key,
    @PathParam('mindmapId') required this.mindmapId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MindmapDetail(
      mindmapId: mindmapId,
      onClose: () => context.router.maybePop(),
      onRetry: () => ref.invalidate(mindmapByIdProvider(mindmapId)),
    );
  }
}
