import 'package:auto_route/auto_route.dart';
import 'package:AIPrimary/core/router/router.gr.dart';
import 'package:AIPrimary/features/projects/domain/entity/shared_resource.dart';
import 'package:AIPrimary/features/projects/enum/resource_type.dart';
import 'package:AIPrimary/features/projects/ui/widgets/common/abstract_resource_card.dart';
import 'package:AIPrimary/shared/pods/translation_pod.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SharedResourceCard extends ConsumerWidget {
  final SharedResource sharedResource;

  const SharedResourceCard({super.key, required this.sharedResource});

  ResourceType _getResourceType(String type) {
    return ResourceType.fromValue(type.toLowerCase());
  }

  void _navigateToDetail(BuildContext context, String type, String resourceId) {
    final resourceType = _getResourceType(type);

    switch (resourceType) {
      case ResourceType.presentation:
        context.router.push(
          PresentationDetailRoute(presentationId: resourceId),
        );
        break;
      case ResourceType.mindmap:
        context.router.push(MindmapDetailRoute(mindmapId: resourceId));
        break;
      case ResourceType.image:
        context.router.push(ImageDetailRoute(imageId: resourceId));
        break;
      case ResourceType.question:
        context.router.push(QuestionDetailRoute(questionId: resourceId));
        break;
      case ResourceType.assignment:
        context.router.push(AssignmentDetailRoute(assignmentId: resourceId));
        break;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(translationsPod);
    final resourceType = _getResourceType(sharedResource.type);

    return AbstractDocumentCard(
      title: sharedResource.title,
      description: t.projects.shared_by(ownerName: sharedResource.ownerName),
      resourceType: resourceType,
      thumbnail: sharedResource.thumbnailUrl,
      onTap: () =>
          _navigateToDetail(context, sharedResource.type, sharedResource.id),
    );
  }
}
