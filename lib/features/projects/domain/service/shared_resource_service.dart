import 'package:datn_mobile/features/projects/domain/entity/shared_resource.dart';

abstract interface class SharedResourceService {
  Future<List<SharedResource>> fetchSharedResources();
}
