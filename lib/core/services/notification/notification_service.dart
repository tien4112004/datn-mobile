import 'dart:async';
import 'dart:convert';

import 'package:AIPrimary/core/services/notification/notification_navigation_handler.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

typedef OnTokenReceived = Future<void> Function(String token);
typedef OnMessageReceived = void Function(RemoteMessage message);

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  static Completer<void>? _initCompleter;
  OnTokenReceived? _onTokenReceived;
  OnMessageReceived? _onMessageReceived;

  void setOnTokenReceived(OnTokenReceived callback) {
    _onTokenReceived = callback;
  }

  void setOnMessageReceived(OnMessageReceived callback) {
    _onMessageReceived = callback;
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
        _onMessageReceived?.call(message);
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
      announcement: true,
      criticalAlert: true,
      provisional: true,
    );
  }

  static const _channelId = 'high_importance_channel';
  static const _channelName = 'High Importance Notifications';

  Future<void> _initializeLocalNotifications() async {
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings(
          requestAlertPermission: true,
          requestBadgePermission: true,
          requestSoundPermission: true,
        );

    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _handleLocalNotificationTap,
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(
          const AndroidNotificationChannel(
            _channelId,
            _channelName,
            importance: Importance.max,
            playSound: true,
            enableVibration: true,
          ),
        );

    // Ensure foreground FCM messages also show alert + sound on iOS
    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
          alert: true,
          badge: true,
          sound: true,
        );
  }

  Future<void> _showLocalNotification(RemoteMessage message) async {
    final title =
        message.notification?.title ?? message.data['title'] as String?;
    final body = message.notification?.body ?? message.data['body'] as String?;

    if (title == null && body == null) return;

    await _localNotifications.show(
      message.hashCode,
      title,
      body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          _channelName,
          importance: Importance.max,
          priority: Priority.high,
          playSound: true,
          enableVibration: true,
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      payload: jsonEncode(message.data),
    );
  }

  void _handleMessageOpenedApp(RemoteMessage message) {
    NotificationNavigationHandler.navigateFromFcmData(message.data);
  }

  void _handleLocalNotificationTap(NotificationResponse response) {
    NotificationNavigationHandler.navigateFromLocalPayload(response.payload);
  }

  Future<String?> getToken() async => await _firebaseMessaging.getToken();
}
