import 'package:datn_mobile/features/classes/domain/entity/linked_resource_preview.dart';
import 'package:datn_mobile/features/classes/domain/entity/linked_resource_entity.dart';
import 'package:datn_mobile/features/projects/service/service_provider.dart';
import 'package:datn_mobile/features/assignments/states/controller_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provider that fetches resource details using known type (optimized, no cascading)
final linkedResourceFetcherProvider =
    FutureProvider.family<LinkedResourcePreview, LinkedResourceEntity>((
      ref,
      resource,
    ) async {
      debugPrint(
        '🔍 [LinkedResource] Fetching: ${resource.type} - ${resource.id}',
      );

      try {
        // Direct lookup using known type - eliminates cascading API calls
        switch (resource.type.toLowerCase()) {
          case 'presentation':
            debugPrint('📊 [Presentation] Fetching ID: ${resource.id}');
            final presentation = await ref
                .read(presentationServiceProvider)
                .fetchPresentationById(resource.id);

            debugPrint('✅ [Presentation] Success: ${presentation.title}');
            return LinkedResourcePreview(
              id: presentation.id,
              title: presentation.title,
              type: 'presentation',
              thumbnail: presentation.thumbnail,
              updatedAt: presentation.updatedAt,
            );

          case 'mindmap':
            final mindmap = await ref
                .read(mindmapServiceProvider)
                .fetchMindmapById(resource.id);

            return LinkedResourcePreview(
              id: mindmap.id,
              title: mindmap.title,
              type: 'mindmap',
              thumbnail: mindmap.thumbnail,
              updatedAt: mindmap.updatedAt,
            );

          case 'assignment':
            debugPrint('📝 [Assignment] Fetching ID: ${resource.id}');
            final assignment = await ref
                .read(assignmentRepositoryProvider)
                .getAssignmentById(resource.id);

            debugPrint('✅ [Assignment] Success: ${assignment.title}');
            return LinkedResourcePreview(
              id: assignment.assignmentId,
              title: assignment.title,
              type: 'assignment',
              updatedAt: assignment.updatedAt,
              subject: assignment.subject.displayName,
              gradeLevel: assignment.gradeLevel.displayName,
              totalQuestions: assignment.totalQuestions,
              totalPoints: assignment.totalPoints,
              status: assignment.status.displayName,
            );

          default:
            // Unknown resource type
            debugPrint(
              '❌ [Error] Unknown resource type: "${resource.type}" for ID: ${resource.id}',
            );
            return LinkedResourcePreview.error(resource.id);
        }
      } catch (e, stackTrace) {
        debugPrint(
          '❌ [Error] Failed to fetch ${resource.type} - ${resource.id}',
        );
        debugPrint('   Error: ${e.toString()}');
        debugPrint(
          '   Stack: ${stackTrace.toString().split('\n').take(3).join('\n')}',
        );

        // Return error preview instead of throwing
        return LinkedResourcePreview.error(resource.id);
      }
    });

/// Batch fetcher for multiple resources
final linkedResourcesBatchFetcherProvider =
    FutureProvider.family<
      Map<String, LinkedResourcePreview>,
      List<LinkedResourceEntity>
    >((ref, resources) async {
      final results = <String, LinkedResourcePreview>{};

      // Fetch all resources in parallel
      final futures = resources.map((resource) async {
        try {
          final preview = await ref.read(
            linkedResourceFetcherProvider(resource).future,
          );
          return MapEntry(resource.id, preview);
        } catch (e) {
          return MapEntry(
            resource.id,
            LinkedResourcePreview.error(resource.id),
          );
        }
      });

      final entries = await Future.wait(futures);
      results.addEntries(entries);

      return results;
    });
