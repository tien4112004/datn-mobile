import 'package:AIPrimary/features/projects/domain/entity/presentation.dart';
import 'package:AIPrimary/features/projects/domain/entity/presentation_minimal.dart';

abstract class PresentationRepository {
  Future<List<PresentationMinimal>> fetchPresentations();
  Future<Presentation> fetchPresentationById(String id);
  Future<void> addPresentation(Presentation presentation);

  Future<List<PresentationMinimal>> fetchPresentationMinimalsPaged(
    int pageKey, {
    int pageSize = 10,
    String sort = "desc",
    String? search,
  });
}
