import 'package:flutter/material.dart';

/// Global route observer used by pages that need to react when they
/// become the top route again (e.g. to refresh stale data).
///
/// Register it in [MaterialApp.router] navigatorObservers and
/// subscribe/unsubscribe in individual page states via [RouteAware].
final PageRouteObserver pageRouteObserver = PageRouteObserver();

class PageRouteObserver extends RouteObserver<ModalRoute<dynamic>> {}
