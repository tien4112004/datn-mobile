import 'package:datn_mobile/core/secure_storage/secure_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage_x/flutter_secure_storage_x.dart';

final flutterSecureStoragePod = Provider<FlutterSecureStorage>((ref) {
  return const FlutterSecureStorage(aOptions: AndroidOptions());
});

final secureStoragePod = Provider<SecureStorage>((ref) {
  final storage = ref.watch(flutterSecureStoragePod);
  return SecureStorage(storage);
});
