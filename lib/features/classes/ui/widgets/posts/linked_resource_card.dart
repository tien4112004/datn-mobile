import 'package:AIPrimary/i18n/strings.g.dart';
import 'package:AIPrimary/shared/pods/translation_pod.dart';
import 'package:auto_route/auto_route.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:AIPrimary/core/router/router.gr.dart';
import 'package:AIPrimary/features/classes/providers/linked_resource_fetcher_provider.dart';
import 'package:AIPrimary/features/classes/domain/entity/linked_resource_entity.dart';
import 'package:AIPrimary/features/classes/domain/entity/linked_resource_preview.dart';
import 'package:AIPrimary/features/classes/domain/entity/permission_level.dart';
import 'package:AIPrimary/features/classes/ui/widgets/posts/assignment_preview_card.dart';
import 'package:AIPrimary/features/projects/enum/resource_type.dart';
import 'package:AIPrimary/shared/riverpod_ext/async_value_easy_when.dart';
import 'package:AIPrimary/shared/widgets/skeleton_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// Card widget that displays a linked resource with details fetched by ID
class LinkedResourceCard extends ConsumerWidget {
  final LinkedResourceEntity resource;

  const LinkedResourceCard({super.key, required this.resource});

  ResourceType? _getResourceType(String type) {
    try {
      return ResourceType.fromValue(type);
    } catch (e) {
      return null;
    }
  }

  void _navigateToDetail(BuildContext context, String type, String id) {
    switch (type) {
      case 'presentation':
        context.router.push(PresentationDetailRoute(presentationId: id));
        break;
      case 'mindmap':
        context.router.push(MindmapDetailRoute(mindmapId: id));
        break;
      case 'image':
        context.router.push(ImageDetailRoute(imageId: id));
        break;
      case 'assignment':
        context.router.push(AssignmentDetailRoute(assignmentId: id));
        break;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(translationsPod);
    // If resource is already enriched by backend, use it directly without API call
    if (resource.title != null) {
      final preview = LinkedResourcePreview(
        id: resource.id,
        title: resource.title!,
        type: resource.type,
        thumbnail: resource.thumbnail,
      );
      return _buildResourceCard(context, preview, t);
    }

    // Otherwise fetch from API (backward compatibility)
    final resourceAsync = ref.watch(linkedResourceFetcherProvider(resource));

    return resourceAsync.easyWhen(
      skipLoadingOnRefresh: false,
      loadingWidget: () => _buildLoadingCard(context),
      errorWidget: (error, stack) {
        return _buildErrorCard(context, error, t);
      },
      data: (preview) {
        return _buildResourceCard(context, preview, t);
      },
    );
  }

  Widget _buildLoadingCard(BuildContext context) {
    return const SkeletonCard(
      badgeCount: 1,
      showSubtitle: true,
      margin: EdgeInsets.zero,
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
    );
  }

  Widget _buildErrorCard(BuildContext context, Object error, Translations t) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: colorScheme.errorContainer.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.error.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(LucideIcons.circleAlert, size: 16, color: colorScheme.error),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  t.classes.linkedResource.notFound,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.error,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  t.classes.linkedResource.unavailable(type: resource.type),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.error.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResourceCard(BuildContext context, preview, Translations t) {
    if (!preview.isValid) {
      return _buildErrorCard(context, t.classes.linkedResource.invalid, t);
    }

    // Use specialized card for assignments
    if (preview.type == 'assignment') {
      return AssignmentPreviewCard(
        preview: preview,
        onTap: () => _navigateToDetail(context, preview.type, preview.id),
      );
    }

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Get resource type for consistent styling
    final resourceType = _getResourceType(preview.type);
    final resourceColor = resourceType?.color ?? colorScheme.secondary;
    final icon = resourceType?.icon ?? LucideIcons.fileText;

    return InkWell(
      onTap: () => _navigateToDetail(context, preview.type, preview.id),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: resourceColor.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: resourceColor.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            // Thumbnail or Icon
            _buildResourceIcon(
              context,
              colorScheme,
              preview.thumbnail,
              icon,
              resourceColor,
            ),

            const SizedBox(width: 12),

            // Title and Type
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    preview.title,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurface,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  // Permission badge
                  _buildPermissionBadge(context, theme, colorScheme, t),
                ],
              ),
            ),

            const SizedBox(width: 8),

            // Arrow Icon
            Icon(
              LucideIcons.arrowRight,
              size: 16,
              color: colorScheme.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResourceIcon(
    BuildContext context,
    ColorScheme colorScheme,
    String? thumbnail,
    IconData icon,
    Color resourceColor,
  ) {
    // Always use icon container as base
    final iconContainer = Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: resourceColor.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(icon, size: 20, color: resourceColor),
    );

    // If thumbnail exists, show it with icon as fallback
    if (thumbnail != null && thumbnail.isNotEmpty) {
      return Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: resourceColor.withValues(alpha: 0.3)),
        ),
        clipBehavior: Clip.antiAlias,
        child: CachedNetworkImage(
          imageUrl: thumbnail,
          fit: BoxFit.cover,
          placeholder: (context, url) => iconContainer,
          errorWidget: (context, url, error) => iconContainer,
        ),
      );
    }

    // No thumbnail - show icon
    return iconContainer;
  }

  Widget _buildPermissionBadge(
    BuildContext context,
    ThemeData theme,
    ColorScheme colorScheme,
    Translations t,
  ) {
    final isCommentPermission =
        resource.permissionLevel == PermissionLevel.comment;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isCommentPermission
            ? colorScheme.primaryContainer
            : colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isCommentPermission ? LucideIcons.messageSquare : LucideIcons.eye,
            size: 12,
            color: isCommentPermission
                ? colorScheme.onPrimaryContainer
                : colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: 4),
          Text(
            isCommentPermission
                ? t.classes.linkedResource.comment
                : t.classes.linkedResource.view,
            style: theme.textTheme.labelSmall?.copyWith(
              color: isCommentPermission
                  ? colorScheme.onPrimaryContainer
                  : colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
