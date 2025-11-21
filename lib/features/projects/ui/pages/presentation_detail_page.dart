import 'package:auto_route/auto_route.dart';
import 'package:datn_mobile/features/projects/states/controller_provider.dart';
import 'package:datn_mobile/features/projects/ui/widgets/presentation/presentation_detail.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// A page that displays a presentation in detail view using a webview.
///
/// The page accepts a presentation ID and fetches the full presentation data
/// from the backend, then displays it in a read-only webview at
/// http://172.16.0.240:5174/
@RoutePage()
class PresentationDetailPage extends ConsumerWidget {
  final String presentationId;

  const PresentationDetailPage({
    super.key,
    @PathParam('presentationId') required this.presentationId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final presentationAsync = ref.watch(
      presentationByIdProvider(presentationId),
    );

    return PresentationDetail(
      presentationAsync: presentationAsync,
      onClose: () => context.router.maybePop(),
      onRetry: () => ref.invalidate(presentationByIdProvider(presentationId)),
    );
  }
}
