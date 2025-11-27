import 'package:datn_mobile/core/secure_storage/secure_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

final flutterSecureStoragePod = Provider<FlutterSecureStorage>((ref) {
  return const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );
});

final secureStoragePod = Provider<SecureStorage>((ref) {
  final storage = ref.watch(flutterSecureStoragePod);
  return SecureStorage(storage);
});
