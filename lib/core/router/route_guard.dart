import 'package:auto_route/auto_route.dart';
import 'package:AIPrimary/const/resource.dart';
import 'package:AIPrimary/core/router/router.gr.dart';
import 'package:AIPrimary/core/secure_storage/secure_storage.dart';

class RouteGuard extends AutoRouteGuard {
  final SecureStorage secureStorage;

  RouteGuard(this.secureStorage);

  @override
  Future<void> onNavigation(
    NavigationResolver resolver,
    StackRouter router,
  ) async {
    final isAuthenticated =
        await secureStorage.read(key: R.ACCESS_TOKEN_KEY) != null;

    if (isAuthenticated) {
      final currentRoute = router.current;
      final isNavigatingToRoot = resolver.route.name == 'MainWrapperRoute';

      if (isNavigatingToRoot && currentRoute.name != 'MainWrapperRoute') {
        router.popUntil((route) => route.settings.name == '/');
      }
      resolver.next(true);
    } else {
      router.replaceAll([const SignInRoute()]);
    }
  }
}
