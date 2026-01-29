part of 'repository_provider.dart';

class SharedResourceRepositoryImpl implements SharedResourceRepository {
  final ProjectsRemoteSource _remoteSource;

  SharedResourceRepositoryImpl(this._remoteSource);

  @override
  Future<List<SharedResource>> fetchSharedResources() async {
    final dtoResponse = await _remoteSource.fetchSharedResources();

    return dtoResponse.data?.map((dto) => dto.toEntity()).toList() ?? [];
  }
}
