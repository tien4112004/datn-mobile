import 'package:flutter/foundation.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';

/// This class used for storing data in nosql hive boxes
/// ,reading data and deleting data .
class AppStorage {
  Box? appBox;

  AppStorage(this.appBox);

  Future<void> init({bool isTest = false}) async {
    appBox =
        appBox ??
        await Hive.openBox('appBox', bytes: isTest ? Uint8List(0) : null);
  }

  /// for getting value as String for a
  /// given key from the box
  String? get({required String key}) {
    return appBox?.get(key) as String?;
  }

  /// for storing value on defined key
  /// on the box
  Future<void> put({required String key, required String value}) async {
    await appBox?.put(key, value);
  }

  /// for getting JSON value for a given key from the box
  Map<String, dynamic>? getJson({required String key}) {
    final value = appBox?.get(key);
    if (value is Map) {
      return Map<String, dynamic>.from(value);
    }
    return null;
  }

  /// for storing JSON value on defined key on the box
  Future<void> putJson({
    required String key,
    required Map<String, dynamic> value,
  }) async {
    await appBox?.put(key, value);
  }

  /// for deleting a specific key from the box
  Future<void> delete({required String key}) async {
    await appBox?.delete(key);
  }

  /// for clearing all data in box
  Future<void> clearAllData() async {
    await appBox?.clear();
  }
}
