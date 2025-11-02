import 'package:datn_mobile/core/theme/app_theme.dart';
import 'package:datn_mobile/features/projects/domain/entity/value_object/slide.dart';
import 'package:datn_mobile/features/projects/enum/resource_type.dart';
import 'package:datn_mobile/features/projects/ui/widgets/common/thumbnail.dart';
import 'package:datn_mobile/shared/pods/translation_pod.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class AbstractDocumentCard extends ConsumerWidget {
  const AbstractDocumentCard({
    super.key,
    required this.title,
    this.description,
    this.createdAt,
    this.thumbnail,
    this.onTap,
    required this.resourceType,
  });

  final String title;
  final String? description;
  final Slide? thumbnail;
  final DateTime? createdAt;
  final VoidCallback? onTap;
  final ResourceType resourceType;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(translationsPod);
    final dateFormat = DateFormat.yMMMd(t.$meta.locale.languageCode);

    return Card(
      shape: const RoundedRectangleBorder(borderRadius: Themes.boxRadius),
      elevation: 4,
      child: InkWell(
        borderRadius: Themes.boxRadius,
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              SizedBox(
                child: thumbnail == null
                    ? DefaultThumbnail(resourceIcon: resourceType.lucideIcon)
                    : const Thumbnail(),
              ),
              const SizedBox(height: 16),
              Column(
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (description != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      description!,
                      style: const TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                  ],
                  if (createdAt != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      t.projects.created_at(
                        date: dateFormat.format(createdAt!),
                      ),
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                  Text(t.projects.type(type: resourceType.getValue())),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
