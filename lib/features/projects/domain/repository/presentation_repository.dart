import 'package:datn_mobile/features/projects/domain/entity/presentation.dart';
import 'package:datn_mobile/features/projects/domain/entity/presentation_minimal.dart';

abstract class PresentationRepository {
  Future<List<PresentationMinimal>> fetchPresentations();
  Future<Presentation> fetchPresentationById(String id);
  Future<void> addPresentation(Presentation presentation);
}
