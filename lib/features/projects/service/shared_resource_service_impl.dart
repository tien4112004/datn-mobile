part of 'service_provider.dart';

class SharedResourceServiceImpl implements SharedResourceService {
  final SharedResourceRepository _repo;

  SharedResourceServiceImpl(this._repo);

  @override
  Future<List<SharedResource>> fetchSharedResources() {
    return _repo.fetchSharedResources();
  }
}
