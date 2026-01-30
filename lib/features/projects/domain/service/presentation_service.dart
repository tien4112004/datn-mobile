import 'package:AIPrimary/features/projects/domain/entity/presentation.dart';
import 'package:AIPrimary/features/projects/domain/entity/presentation_minimal.dart';
import 'package:AIPrimary/features/projects/enum/sort_option.dart';

abstract interface class PresentationService {
  Future<List<PresentationMinimal>> fetchPresentations();
  Future<Presentation> fetchPresentationById(String id);
  Future<void> addPresentation(Presentation presentation);

  Future<List<PresentationMinimal>> fetchPresentationMinimalsPaged(
    int pageKey, {
    String? search,
    SortOption? sort,
  });
}
