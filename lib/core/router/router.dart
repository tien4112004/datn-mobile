import 'package:auto_route/auto_route.dart';
import 'package:datn_mobile/core/router/route_guard.dart';
import 'package:datn_mobile/core/router/router.gr.dart';
import 'package:datn_mobile/core/secure_storage/secure_storage.dart';

/// This class used for defined routes and paths and other properties
@AutoRouterConfig()
class AppRouter extends RootStackRouter {
  final SecureStorage secureStorage;

  AppRouter({required this.secureStorage}) : super();

  @override
  late final List<AutoRoute> routes = [
    AutoRoute(
      page: MainWrapperRoute.page,
      initial: true,
      guards: [RouteGuard(secureStorage)],
      path: '/',
      children: [
        AutoRoute(page: HomeRoute.page),
        AutoRoute(page: ProjectsRoute.page, path: 'projects'),
        AutoRoute(page: SettingRoute.page, path: 'settings'),
        AutoRoute(page: PlaceholderRouteSchedule.page, path: 'schedules'),
        AutoRoute(page: PlaceholderRouteAnnounce.page, path: 'announces'),
      ],
    ),

    // Resource Routes
    AutoRoute(page: PresentationListRoute.page, path: '/presentations'),
    AutoRoute(page: MindmapListRoute.page, path: '/mindmaps'),
    AutoRoute(page: ImageListRoute.page, path: '/images'),

    // Generate Routes
    AutoRoute(page: GenerateRoute.page, path: '/generate'),
    AutoRoute(page: PresentationGenerateRoute.page, path: '/presentation'),
    AutoRoute(
      page: PresentationCustomizationRoute.page,
      path: '/presentation/customize',
    ),
    AutoRoute(page: OutlineEditorRoute.page, path: '/outline-editor'),
    AutoRoute(page: MindmapGenerateRoute.page, path: '/mindmap'),
    AutoRoute(page: MindmapResultRoute.page, path: '/mindmap/result'),
    AutoRoute(page: ImageGenerateRoute.page, path: '/image'),
    AutoRoute(page: ImageResultRoute.page, path: '/image/result'),

    // Detail & Auth Routes
    AutoRoute(
      page: PresentationDetailRoute.page,
      path: '/presentation/:presentationId',
    ),
    AutoRoute(page: SignInRoute.page, path: '/sign-in'),
    AutoRoute(page: SignUpRoute.page, path: '/sign-up'),
    AutoRoute(
      page: PresentationSearchRoute.page,
      path: '/search/presentations',
    ),
    AutoRoute(page: MindmapSearchRoute.page, path: '/search/mindmaps'),
    AutoRoute(page: ImageSearchRoute.page, path: '/search/images'),
  ];
}
