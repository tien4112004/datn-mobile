part of 'service_provider.dart';

class PresentationServiceImpl implements PresentationService {
  final PresentationRepository _repo;
  PresentationServiceImpl(this._repo);

  @override
  Future<List<PresentationMinimal>> fetchPresentations() {
    return _repo.fetchPresentations();
  }

  @override
  Future<Presentation> fetchPresentationById(String id) {
    return _repo.fetchPresentationById(id);
  }

  @override
  Future<void> addPresentation(Presentation presentation) {
    // Additional validations or logics
    return _repo.addPresentation(presentation);
  }
}
