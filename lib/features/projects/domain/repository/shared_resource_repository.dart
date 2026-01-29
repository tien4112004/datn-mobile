import 'package:datn_mobile/features/projects/domain/entity/shared_resource.dart';

abstract class SharedResourceRepository {
  Future<List<SharedResource>> fetchSharedResources();
}
