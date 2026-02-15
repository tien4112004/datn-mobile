import 'package:AIPrimary/features/home/data/models/at_risk_student_model.dart';
import 'package:AIPrimary/features/home/data/models/calendar_event_model.dart';
import 'package:AIPrimary/features/home/data/models/class_at_risk_students_model.dart';
import 'package:AIPrimary/features/home/data/models/class_performance_model.dart';
import 'package:AIPrimary/features/home/data/models/grading_queue_model.dart';
import 'package:AIPrimary/features/home/data/models/item_analysis_model.dart';
import 'package:AIPrimary/features/home/data/models/recent_activity_model.dart';
import 'package:AIPrimary/features/home/data/models/student_performance_model.dart';
import 'package:AIPrimary/features/home/data/models/teacher_summary_model.dart';
import 'package:AIPrimary/shared/api_client/response_dto/server_reponse_dto.dart';
import 'package:retrofit/retrofit.dart';
import 'package:dio/dio.dart';

part 'analytics_remote_source.g.dart';

/// Retrofit API service for Analytics endpoints.
@RestApi()
abstract class AnalyticsRemoteSource {
  factory AnalyticsRemoteSource(Dio dio, {String baseUrl}) =
      _AnalyticsRemoteSource;

  /// Get Teacher Summary
  /// GET /analytics/teacher/summary
  @GET('/analytics/teacher/summary')
  Future<ServerResponseDto<TeacherSummaryModel>> getTeacherSummary();

  /// Get Teacher Calendar
  /// GET /analytics/teacher/calendar
  @GET('/analytics/teacher/calendar')
  Future<ServerResponseDto<List<CalendarEventModel>>> getTeacherCalendar({
    @Query('startDate') String? startDate,
    @Query('endDate') String? endDate,
  });

  /// Get Grading Queue
  /// GET /analytics/teacher/grading-queue
  @GET('/analytics/teacher/grading-queue')
  Future<ServerResponseDto<List<GradingQueueItemModel>>> getGradingQueue({
    @Query('page') int? page,
    @Query('size') int? size,
  });

  /// Get At-Risk Students by Class (legacy endpoint)
  /// GET /analytics/teacher/students/at-risk/{classId}
  @GET('/analytics/teacher/students/at-risk/{classId}')
  Future<ServerResponseDto<List<AtRiskStudentModel>>> getAtRiskStudents(
    @Path('classId') String classId,
  );

  /// Get All Classes with At-Risk Students
  /// GET /analytics/teacher/students/at-risk
  @GET('/analytics/teacher/students/at-risk')
  Future<ServerResponseDto<List<ClassAtRiskStudentsModel>>>
  getAllClassesAtRiskStudents();

  /// Get Recent Activity
  /// GET /analytics/teacher/recent-activity
  @GET('/analytics/teacher/recent-activity')
  Future<ServerResponseDto<List<RecentActivityModel>>> getRecentActivity({
    @Query('limit') int? limit,
  });

  /// Get Class Performance
  /// GET /analytics/teacher/classes/{classId}/performance
  @GET('/analytics/teacher/classes/{classId}/performance')
  Future<ServerResponseDto<ClassPerformanceModel>> getClassPerformance(
    @Path('classId') String classId,
  );

  /// Get Item Analysis
  /// GET /analytics/assignments/{assignmentId}/item-analysis
  @GET('/analytics/assignments/{assignmentId}/item-analysis')
  Future<ServerResponseDto<ItemAnalysisModel>> getItemAnalysis(
    @Path('assignmentId') String assignmentId,
  );

  /// Get Student Calendar
  /// GET /analytics/student/calendar
  @GET('/analytics/student/calendar')
  Future<ServerResponseDto<List<CalendarEventModel>>> getStudentCalendar({
    @Query('startDate') String? startDate,
    @Query('endDate') String? endDate,
  });

  /// Get Student Performance
  /// GET /analytics/student/performance
  @GET('/analytics/student/performance')
  Future<ServerResponseDto<StudentPerformanceModel>> getStudentPerformance();

  /// Get Specific Student Performance (for teachers)
  /// GET /analytics/teacher/students/{studentId}/performance
  @GET('/analytics/teacher/students/{studentId}/performance')
  Future<ServerResponseDto<StudentPerformanceModel>> getStudentPerformanceById(
    @Path('studentId') String studentId,
  );
}
