import 'dart:convert';
import 'package:datn_mobile/features/auth/domain/entities/user_profile.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorage {
  // Placeholder for secure storage implementation
  final FlutterSecureStorage storage;

  static const String _userProfileKey = 'user_profile';

  SecureStorage(this.storage);

  Future<void> write({required String key, required String value}) async {
    await storage.write(key: key, value: value);
  }

  Future<String?> read({required String key}) async {
    final value = await storage.read(key: key);
    return value;
  }

  Future<void> delete({required String key}) async {
    await storage.delete(key: key);
  }

  Future containsKey(String s) async {
    return await storage.containsKey(key: s);
  }

  // User profile specific methods
  Future<void> saveUserProfile(UserProfile profile) async {
    final jsonString = jsonEncode(profile.toJson());
    await write(key: _userProfileKey, value: jsonString);
  }

  Future<UserProfile?> loadUserProfile() async {
    final jsonString = await read(key: _userProfileKey);
    if (jsonString == null) return null;

    try {
      final jsonMap = jsonDecode(jsonString) as Map<String, dynamic>;
      return UserProfile.fromJson(jsonMap);
    } catch (e) {
      // If parsing fails, delete the corrupted data
      await deleteUserProfile();
      return null;
    }
  }

  Future<void> deleteUserProfile() async {
    await delete(key: _userProfileKey);
  }
}
