import 'package:auto_route/auto_route.dart';
import 'package:datn_mobile/const/resource.dart';
import 'package:datn_mobile/core/router/router.gr.dart';
import 'package:datn_mobile/core/secure_storage/secure_storage.dart';

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
      resolver.next(true);
    } else {
      router.replace(const SignInRoute());
    }
  }
}
