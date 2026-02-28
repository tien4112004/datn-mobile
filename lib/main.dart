import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:AIPrimary/splasher.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:AIPrimary/core/services/notification/notification_service.dart';
import 'package:AIPrimary/firebase_options.dart';

/// Top-level function required by firebase_messaging for background handling.
/// Runs in an isolate — cannot access Riverpod or UI.
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  // Background data-only messages are handled here.
  // Notification messages are shown automatically by the OS using the
  // channel declared in AndroidManifest.xml.
}

/// This entry point should be used for production only
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  await NotificationService().initialize();

  runApp(const ProviderScope(child: Splasher()));
}
