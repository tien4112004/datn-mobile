import 'package:datn_mobile/features/profile/domain/service/profile_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

part 'profile_service_impl.dart';

final profileServiceProvider = Provider<ProfileService>((ref) {
  return ProfileServiceImpl();
});
