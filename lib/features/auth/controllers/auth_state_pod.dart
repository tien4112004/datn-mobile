import 'package:AIPrimary/const/resource.dart';
import 'package:AIPrimary/core/secure_storage/secure_storage_pod.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provider that checks if user is authenticated by checking for access token
final authStatePod = FutureProvider<bool>((ref) async {
  final secureStorage = ref.watch(secureStoragePod);
  final accessToken = await secureStorage.read(key: R.ACCESS_TOKEN_KEY);
  return accessToken != null && accessToken.isNotEmpty;
});
