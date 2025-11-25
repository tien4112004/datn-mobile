import 'package:flutter/widgets.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorage {
  // Placeholder for secure storage implementation
  final FlutterSecureStorage storage;

  SecureStorage(this.storage);

  Future<void> write({required String key, required String value}) async {
    debugPrint('Writing to secure storage: key=$key, value=$value');
    await storage.write(key: key, value: value);
  }

  Future<String?> read({required String key}) async {
    final value = await storage.read(key: key);
    debugPrint('Reading from secure storage: key=$key => value=$value');
    return value;
  }

  Future<void> delete({required String key}) async {
    debugPrint('Deleting from secure storage: key=$key');
    await storage.delete(key: key);
  }
}
