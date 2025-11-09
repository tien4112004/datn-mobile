import 'package:datn_mobile/core/secure_storage/secure_storage_pod.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:datn_mobile/core/router/router.dart';

/// This global variable used for global working on ui elements where
/// may be context is not present
final navigatorKey = GlobalKey<NavigatorState>();

/// This provider used for storing router
/// and can be acessed by reading it using ProviderRef/WidgetRef
final autorouterProvider = Provider.autoDispose<AppRouter>((ref) {
  final secureStorage = ref.read(secureStoragePod);
  return AppRouter(secureStorage: secureStorage);
});
