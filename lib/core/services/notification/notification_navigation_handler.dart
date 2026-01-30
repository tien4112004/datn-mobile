import 'dart:convert';

import 'package:auto_route/auto_route.dart';
import 'package:AIPrimary/core/router/router.gr.dart';
import 'package:AIPrimary/features/notification/domain/entity/app_notification.dart';
import 'package:AIPrimary/features/notification/domain/entity/notification_type.dart';
import 'package:AIPrimary/features/notification/domain/entity/resource_type.dart';
import 'package:flutter/widgets.dart';

class NotificationNavigationHandler {
  NotificationNavigationHandler._();

  /// Registered router instance - set when App widget mounts
  static StackRouter? _router;

  /// Pending navigation data for when router isn't ready yet
  static Map<String, dynamic>? _pendingNavigationData;

  /// Register the router - called from App widget when router is available
  /// Also processes any pending navigation that was queued before router was ready
  static void registerRouter(StackRouter router) {
    _router = router;

    // Process any pending navigation that arrived before router was ready
    if (_pendingNavigationData != null) {
      final data = _pendingNavigationData!;
      _pendingNavigationData = null;
      debugPrint(
        'Processing pending navigation after router registration: $data',
      );
      _navigateWithRouter(router, data);
    }
  }

  /// Unregister the router - called when App widget disposes
  static void unregisterRouter() {
    _router = null;
  }

  /// Internal method to perform navigation with a given router
  static void _navigateWithRouter(
    StackRouter router,
    Map<String, dynamic> data,
  ) {
    // Use addPostFrameCallback to ensure navigation happens after current frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final route = _getRouteFromData(data);
      if (route != null) {
        debugPrint('Navigating to route: $route');
        router.push(route);
      } else {
        debugPrint('No route found for data: $data');
      }
    });
  }

  /// For UI list taps - context is available, navigate immediately
  static void navigateFromAppNotification(
    AppNotification notification,
    BuildContext context,
  ) {
    final router = AutoRouter.of(context);
    final route = _getRouteForType(notification.type, notification.referenceId);
    if (route != null) {
      router.push(route);
    }
  }

  /// For FCM message taps - navigate immediately if router is ready,
  /// otherwise store for deferred navigation
  static void navigateFromFcmData(Map<String, dynamic> data) {
    if (_router != null) {
      // Router is available - navigate immediately
      debugPrint('Router available, navigating immediately');
      _navigateWithRouter(_router!, data);
    } else {
      // Router not ready yet - store for later processing
      debugPrint('Router not ready, storing for deferred navigation');
      _pendingNavigationData = Map<String, dynamic>.from(data);
    }
  }

  /// For local notification taps - parse payload and store data
  static void navigateFromLocalPayload(String? payload) {
    if (payload == null || payload.isEmpty) return;

    try {
      final data = jsonDecode(payload) as Map<String, dynamic>;
      navigateFromFcmData(data);
    } catch (_) {
      // Invalid JSON payload, ignore
    }
  }

  static PageRouteInfo? _getRouteFromData(Map<String, dynamic> data) {
    // Primary: type + referenceId (consistent with AppNotification entity)
    final typeString = data['type'] as String?;
    final referenceId = data['referenceId'] as String?;

    if (typeString != null) {
      final type = NotificationType.fromString(typeString);
      return _getRouteForType(type, referenceId);
    }

    // Fallback: Legacy resourceType + documentId format (backward compatibility)
    final resourceTypeString = data['resourceType'] as String?;
    final documentId = data['documentId'] as String?;

    if (resourceTypeString != null && documentId != null) {
      final resourceType = ResourceType.fromString(resourceTypeString);
      if (resourceType != null) {
        return _getRouteForResourceType(resourceType, documentId);
      }
    }

    return null;
  }

  static PageRouteInfo? _getRouteForResourceType(
    ResourceType resourceType,
    String documentId,
  ) {
    switch (resourceType) {
      case ResourceType.presentation:
        return PresentationDetailRoute(presentationId: documentId);
      case ResourceType.mindmap:
        return MindmapDetailRoute(mindmapId: documentId);
      case ResourceType.image:
        return ImageDetailRoute(imageId: documentId);
    }
  }

  static PageRouteInfo? _getRouteForType(
    NotificationType type,
    String? referenceId,
  ) {
    debugPrint(
      'Getting route for notification type: $type, referenceId: $referenceId',
    );
    switch (type) {
      case NotificationType.sharedPresentation:
        if (referenceId == null) return null;
        return PresentationDetailRoute(presentationId: referenceId);

      case NotificationType.sharedMindmap:
        if (referenceId == null) return null;
        return MindmapDetailRoute(mindmapId: referenceId);

      case NotificationType.assignment:
      case NotificationType.grade:
        if (referenceId == null) return null;
        return AssignmentDetailRoute(assignmentId: referenceId);

      case NotificationType.post:
      case NotificationType.comment:
        if (referenceId == null) return null;
        return ClassDetailRoute(classId: referenceId);

      case NotificationType.announcement:
      case NotificationType.reminder:
      case NotificationType.system:
        // These types don't have detail pages
        return null;
    }
  }
}
