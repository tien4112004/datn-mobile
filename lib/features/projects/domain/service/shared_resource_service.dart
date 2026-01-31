import 'package:AIPrimary/features/projects/domain/entity/shared_resource.dart';

abstract interface class SharedResourceService {
  Future<List<SharedResource>> fetchSharedResources();
}
