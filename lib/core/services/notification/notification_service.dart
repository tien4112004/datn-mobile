import 'dart:async';
import 'dart:convert';

import 'package:AIPrimary/core/services/notification/notification_navigation_handler.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

typedef OnTokenReceived = Future<void> Function(String token);

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  static Completer<void>? _initCompleter;
  OnTokenReceived? _onTokenReceived;

  void setOnTokenReceived(OnTokenReceived callback) {
    _onTokenReceived = callback;
  }

  Future<void> initialize() async {
    if (_initCompleter != null) {
      return _initCompleter!.future;
    }

    _initCompleter = Completer<void>();

    try {
      await _requestPermission();
      await _initializeLocalNotifications();

      final token = await _firebaseMessaging.getToken();
      if (token != null && _onTokenReceived != null) {
        await _onTokenReceived!(token);
      }

      _firebaseMessaging.onTokenRefresh.listen((newToken) async {
        if (_onTokenReceived != null) {
          await _onTokenReceived!(newToken);
        }
      });

      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        _showLocalNotification(message);
      });

      FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageOpenedApp);

      // Handle app opened from terminated state via notification tap
      final initialMessage = await _firebaseMessaging.getInitialMessage();
      if (initialMessage != null) {
        _handleMessageOpenedApp(initialMessage);
      }

      _initCompleter!.complete();
    } catch (e) {
      _initCompleter!.completeError(e);
      rethrow;
    }
  }

  Future<void> _requestPermission() async {
    await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
  }

  Future<void> _initializeLocalNotifications() async {
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings();

    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _handleLocalNotificationTap,
    );
  }

  Future<void> _showLocalNotification(RemoteMessage message) async {
    RemoteNotification? notification = message.notification;
    AndroidNotification? android = message.notification?.android;

    if (notification != null && android != null) {
      await _localNotifications.show(
        notification.hashCode,
        notification.title,
        notification.body,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'high_importance_channel',
            'High Importance Notifications',
            importance: Importance.max,
            priority: Priority.high,
          ),
          iOS: DarwinNotificationDetails(),
        ),
        payload: jsonEncode(message.data),
      );
    }
  }

  void _handleMessageOpenedApp(RemoteMessage message) {
    NotificationNavigationHandler.navigateFromFcmData(message.data);
  }

  void _handleLocalNotificationTap(NotificationResponse response) {
    NotificationNavigationHandler.navigateFromLocalPayload(response.payload);
  }

  Future<String?> getToken() async => await _firebaseMessaging.getToken();
}
