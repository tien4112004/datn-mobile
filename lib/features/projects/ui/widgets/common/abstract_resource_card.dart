import 'dart:developer';
import 'dart:ffi';

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

  int _getDateDiffFromNow(DateTime date) {
    log('Date: $date');
    final now = DateTime.now();
    return now.difference(date).inDays;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(translationsPod);
    final dateFormat = _getDateDiffFromNow(createdAt ?? DateTime.now());

    return Card(
      shape: const RoundedRectangleBorder(borderRadius: Themes.boxRadius),
      color: Colors.transparent,
      shadowColor: Colors.transparent,
      child: InkWell(
        borderRadius: Themes.boxRadius,
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(0.0),
          child: SizedBox(
            width: 112,
            child: Column(
              children: [
                Container(
                  height: 82,
                  decoration: BoxDecoration(
                    borderRadius: Themes.boxRadius,
                    color: Colors.grey.shade100,
                  ),
                  child: thumbnail == null
                      ? DefaultThumbnail(resourceIcon: resourceType.lucideIcon)
                      : const Thumbnail(),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: Themes.fontSize.s16,
                        fontWeight: FontWeight.bold,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (description != null) ...[
                      Text(
                        description!,
                        style: TextStyle(
                          fontSize: Themes.fontSize.s12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                    if (createdAt != null) ...[
                      Text(
                        t.projects.edited(date: dateFormat),
                        style: TextStyle(
                          fontSize: Themes.fontSize.s12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                    Text(
                      t.projects.type(type: resourceType.getValue()),
                      style: TextStyle(
                        fontSize: Themes.fontSize.s12,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
