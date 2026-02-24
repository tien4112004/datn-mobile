import 'package:auto_route/auto_route.dart';
import 'package:AIPrimary/core/router/route_guard.dart';
import 'package:AIPrimary/core/router/router.gr.dart';
import 'package:AIPrimary/core/secure_storage/secure_storage.dart';

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
        AutoRoute(page: ClassRoute.page, path: 'classes'),
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
    AutoRoute(
      page: PresentationGenerationWebViewRoute.page,
      path: '/presentation/generate/view',
    ),
    AutoRoute(page: OutlineEditorRoute.page, path: '/outline-editor'),
    AutoRoute(page: MindmapGenerateRoute.page, path: '/mindmap'),
    AutoRoute(page: MindmapResultRoute.page, path: '/mindmap/result'),
    AutoRoute(
      page: MindmapGenerationWebViewRoute.page,
      path: '/mindmap/generate/view',
    ),
    AutoRoute(page: MindmapDetailRoute.page, path: '/mindmap/:mindmapId'),
    AutoRoute(page: ImageGenerateRoute.page, path: '/image'),
    AutoRoute(page: ImageResultRoute.page, path: '/image/result'),

    // Detail & Auth Routes
    AutoRoute(
      page: PresentationDetailRoute.page,
      path: '/presentation/:presentationId',
    ),
    AutoRoute(page: ImageDetailRoute.page, path: '/image/:imageId'),
    AutoRoute(page: SignInRoute.page, path: '/sign-in'),
    AutoRoute(page: SignUpRoute.page, path: '/sign-up'),
    AutoRoute(
      page: PersonalInformationRoute.page,
      path: '/personal-information',
      guards: [RouteGuard(secureStorage)],
    ), // Class Routes
    AutoRoute(page: ClassDetailRoute.page, path: '/classes/:classId'),
    AutoRoute(page: ClassEditRoute.page, path: '/classes/:classId/edit'),

    // Student Routes
    AutoRoute(page: StudentListRoute.page, path: '/classes/:classId/students'),
    AutoRoute(page: StudentDetailRoute.page, path: '/students/:studentId'),
    AutoRoute(
      page: StudentCreateRoute.page,
      path: '/classes/:classId/students/create',
    ),
    AutoRoute(
      page: StudentEditRoute.page,
      path: '/classes/:classId/students/:studentId/edit',
    ),

    // Notification Routes
    AutoRoute(page: NotificationListRoute.page, path: '/notifications'),

    // Payment Routes
    AutoRoute(page: PaymentMethodsRoute.page, path: '/payment-methods'),
    AutoRoute(page: CoinPurchaseRoute.page, path: '/purchase-coins'),
    AutoRoute(page: PaymentWebViewRoute.page, path: '/payment-webview'),
    AutoRoute(page: TransactionHistoryRoute.page, path: '/transaction-history'),
    AutoRoute(
      page: TransactionDetailRoute.page,
      path: '/transaction/:transactionId',
    ),

    // Exam Routes
    AutoRoute(page: AssignmentsRoute.page, path: '/assignments'),
    AutoRoute(
      page: AssignmentDetailRoute.page,
      path: '/assignments/:assignmentId',
    ),

    // Submission Routes
    AutoRoute(
      page: AssignmentPreviewRoute.page,
      path: '/assignments/:assignmentId/preview',
    ),
    AutoRoute(
      page: AssignmentDoingRoute.page,
      path: '/assignments/:assignmentId/do',
    ),
    AutoRoute(
      page: SubmissionDetailRoute.page,
      path: '/submissions/:submissionId',
    ),
    AutoRoute(
      page: GradingRoute.page,
      path: '/submissions/:submissionId/grade',
    ),
    AutoRoute(
      page: SubmissionsListRoute.page,
      path: '/posts/:postId/submissions',
    ),
    AutoRoute(
      page: AssignmentStatisticsRoute.page,
      path: '/posts/:postId/statistics',
    ),

    AutoRoute(page: QuestionBankRoute.page, path: '/questions-bank'),
    AutoRoute(
      page: QuestionBankPickerRoute.page,
      path: '/questions-bank/picker',
    ),
    AutoRoute(page: QuestionDetailRoute.page, path: '/questions/:questionId'),
    AutoRoute(
      page: QuestionUpdateRoute.page,
      path: '/questions/:questionId/edit',
    ),
    AutoRoute(page: QuestionCreateRoute.page, path: '/questions/create'),
    AutoRoute(page: QuestionGenerateRoute.page, path: '/questions/generate'),
    AutoRoute(
      page: QuestionGenerateResultRoute.page,
      path: '/questions/generate/result',
    ),
    AutoRoute(
      page: AssignmentQuestionEditRoute.page,
      path: '/assignments/questions/edit',
    ),
    AutoRoute(
      page: AssignmentQuestionCreateRoute.page,
      path: '/assignments/questions/create',
    ),
    AutoRoute(page: ContextEditRoute.page, path: '/assignments/context/edit'),
    AutoRoute(
      page: AssignmentDraftReviewRoute.page,
      path: '/assignments/draft-review',
    ),
  ];
}
