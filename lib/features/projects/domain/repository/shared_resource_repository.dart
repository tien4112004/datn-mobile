import 'package:AIPrimary/features/projects/domain/entity/shared_resource.dart';

abstract class SharedResourceRepository {
  Future<List<SharedResource>> fetchSharedResources();
}
