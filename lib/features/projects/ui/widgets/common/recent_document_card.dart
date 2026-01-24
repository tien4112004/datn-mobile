import 'package:auto_route/auto_route.dart';
import 'package:datn_mobile/core/router/router.gr.dart';
import 'package:datn_mobile/features/projects/domain/entity/recent_document.dart';
import 'package:datn_mobile/features/projects/enum/resource_type.dart';
import 'package:datn_mobile/features/projects/ui/widgets/common/abstract_resource_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class RecentDocumentCard extends ConsumerWidget {
  final RecentDocument recentDocument;

  const RecentDocumentCard({super.key, required this.recentDocument});

  ResourceType _getResourceType(String documentType) {
    return ResourceType.fromValue(documentType.toLowerCase());
  }

  void _navigateToDetail(
    BuildContext context,
    String documentType,
    String documentId,
  ) {
    final resourceType = _getResourceType(documentType);

    switch (resourceType) {
      case ResourceType.presentation:
        context.router.push(
          PresentationDetailRoute(presentationId: documentId),
        );
        break;
      case ResourceType.mindmap:
        context.router.push(MindmapDetailRoute(mindmapId: documentId));
        break;
      case ResourceType.image:
        context.router.push(ImageDetailRoute(imageId: documentId));
        break;
      case ResourceType.question:
        context.router.push(QuestionDetailRoute(questionId: documentId));
        break;
      case ResourceType.assignment:
        context.router.push(AssignmentDetailRoute(assignmentId: documentId));
        break;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final resourceType = _getResourceType(recentDocument.documentType);

    return AbstractDocumentCard(
      title: recentDocument.title,
      createdAt: recentDocument.lastVisited,
      resourceType: resourceType,
      thumbnail: recentDocument.thumbnail,
      onTap: () => _navigateToDetail(
        context,
        recentDocument.documentType,
        recentDocument.documentId,
      ),
    );
  }
}
