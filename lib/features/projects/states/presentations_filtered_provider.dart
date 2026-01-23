import 'package:datn_mobile/features/projects/domain/entity/presentation_minimal.dart';
import 'package:datn_mobile/features/projects/enum/sort_option.dart';
import 'package:datn_mobile/features/projects/service/service_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provider for filtered presentations list with search and sort support.
///
/// This provider follows the AsyncValue pattern for consistency with
/// question bank and other list pages.
///
/// Usage:
/// ```dart
/// final presentationsAsync = ref.watch(
///   filteredPresentationsProvider((searchQuery, sortOption)),
/// );
///
/// presentationsAsync.easyWhen(
///   data: (presentations) => ListView(...),
///   loadingWidget: () => SkeletonLoading(),
/// );
/// ```
final filteredPresentationsProvider = FutureProvider.autoDispose
    .family<List<PresentationMinimal>, (String?, SortOption?)>((
      ref,
      params,
    ) async {
      final searchQuery = params.$1;
      final sortOption = params.$2;

      // Fetch presentations with search and sort filters
      // Using page 1 - in a real app you might want to handle pagination differently
      final presentations = await ref
          .read(presentationServiceProvider)
          .fetchPresentationMinimalsPaged(
            1,
            search: searchQuery?.isEmpty == true ? null : searchQuery,
            sort: sortOption,
          );

      return presentations;
    });
