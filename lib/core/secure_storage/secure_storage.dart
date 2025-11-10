import 'dart:developer';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorage {
  // Placeholder for secure storage implementation
  final FlutterSecureStorage storage;

  SecureStorage(this.storage);

  Future<void> write({required String key, required String value}) async {
    log('Writing to secure storage: key=$key, value=$value');
    await storage.write(key: key, value: value);
  }

  Future<String?> read({required String key}) async {
    return await storage.read(key: key);
  }

  Future<void> delete({required String key}) async {
    await storage.delete(key: key);
  }

  String? readSync({required String key}) {
    // Note: FlutterSecureStorage does not support synchronous read.
    // This is just a placeholder to match the original code structure.
    log('Synchronous read is not supported. Use read() instead.');
    return null;
  }
}
