import 'package:AIPrimary/shared/pods/translation_pod.dart';
import 'package:auto_route/auto_route.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:AIPrimary/core/router/router.gr.dart';
import 'package:AIPrimary/features/projects/domain/entity/image_project_minimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class ImageGalleryView extends ConsumerWidget {
  final PagingController<int, ImageProjectMinimal> pagingController;
  final Function(ImageProjectMinimal)? onImageTap;
  final Function(ImageProjectMinimal)? onMoreOptions;

  const ImageGalleryView({
    super.key,
    required this.pagingController,
    this.onImageTap,
    this.onMoreOptions,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(translationsPod);

    return PagingListener(
      controller: pagingController,
      builder: (context, state, fetchNextPage) {
        return PagedMasonryGridView<int, ImageProjectMinimal>.count(
          crossAxisCount: 2,
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
          padding: const EdgeInsets.all(8),
          state: state,
          fetchNextPage: fetchNextPage,
          builderDelegate: PagedChildBuilderDelegate(
            itemBuilder: (context, item, index) {
              return _ImageGalleryTile(
                image: item,
                onTap: onImageTap != null ? () => onImageTap!(item) : null,
                onMoreOptions: onMoreOptions != null
                    ? () => onMoreOptions!(item)
                    : null,
                t: t,
              );
            },
            firstPageErrorIndicatorBuilder: (context) => _ErrorIndicator(
              error: state.error.toString(),
              onRetry: () => pagingController.refresh(),
              t: t,
            ),
            noItemsFoundIndicatorBuilder: (context) => _EmptyIndicator(t: t),
            newPageProgressIndicatorBuilder: (context) => const Padding(
              padding: EdgeInsets.all(24),
              child: Center(
                child: SizedBox(
                  width: 32,
                  height: 32,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            ),
            newPageErrorIndicatorBuilder: (context) =>
                _NewPageErrorIndicator(onRetry: fetchNextPage, t: t),
          ),
        );
      },
    );
  }
}

class _ImageGalleryTile extends StatelessWidget {
  final ImageProjectMinimal image;
  final VoidCallback? onTap;
  final VoidCallback? onMoreOptions;
  final dynamic t;

  const _ImageGalleryTile({
    required this.image,
    this.onTap,
    this.onMoreOptions,
    required this.t,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        if (onTap != null) {
          onTap!();
        } else {
          context.router.push(ImageDetailRoute(imageId: image.id));
        }
      },
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: colorScheme.outlineVariant.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Stack(
          children: [
            // Image
            Hero(
              tag: 'image_${image.id}',
              child: CachedNetworkImage(
                imageUrl: image.url,
                fit: BoxFit.contain,
                fadeInDuration: const Duration(milliseconds: 200),
                fadeOutDuration: const Duration(milliseconds: 200),
                placeholder: (context, url) => Container(
                  color: colorScheme.surfaceContainerHighest,
                  height: 200,
                  child: Center(
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: colorScheme.primary,
                    ),
                  ),
                ),
                errorWidget: (context, url, error) => Container(
                  color: colorScheme.errorContainer,
                  height: 200,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        LucideIcons.imageOff,
                        size: 48,
                        color: colorScheme.onErrorContainer,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        t.projects.common_list.failed_to_load,
                        style: TextStyle(
                          color: colorScheme.onErrorContainer,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // Options button overlay
            if (onMoreOptions != null)
              Positioned(
                top: 8,
                right: 8,
                child: GestureDetector(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    onMoreOptions!();
                  },
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.5),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      LucideIcons.ellipsisVertical,
                      size: 18,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _EmptyIndicator extends StatelessWidget {
  final dynamic t;
  const _EmptyIndicator({required this.t});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(LucideIcons.image, size: 64, color: colorScheme.outline),
          const SizedBox(height: 16),
          Text(
            t.projects.common_list.no_items_title(
              type: t.projects.images.title,
            ),
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            t.projects.common_list.no_items_description(
              type: t.projects.images.title,
            ),
            style: TextStyle(fontSize: 14, color: colorScheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}

class _ErrorIndicator extends StatelessWidget {
  final String error;
  final VoidCallback onRetry;
  final dynamic t;

  const _ErrorIndicator({
    required this.error,
    required this.onRetry,
    required this.t,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(LucideIcons.circleAlert, size: 64, color: colorScheme.error),
          const SizedBox(height: 16),
          Text(
            t.projects.common_list.error_load(type: t.projects.images.title),
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            error,
            style: TextStyle(fontSize: 14, color: colorScheme.onSurfaceVariant),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: onRetry,
            icon: const Icon(LucideIcons.refreshCw),
            label: Text(t.projects.common_list.retry),
          ),
        ],
      ),
    );
  }
}

class _NewPageErrorIndicator extends StatelessWidget {
  final VoidCallback onRetry;
  final dynamic t;

  const _NewPageErrorIndicator({required this.onRetry, required this.t});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: Column(
          children: [
            Text(
              t.projects.common_list.error_load_more,
              style: TextStyle(
                fontSize: 14,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            TextButton.icon(
              onPressed: onRetry,
              icon: const Icon(LucideIcons.refreshCw, size: 16),
              label: Text(t.projects.common_list.retry),
            ),
          ],
        ),
      ),
    );
  }
}
