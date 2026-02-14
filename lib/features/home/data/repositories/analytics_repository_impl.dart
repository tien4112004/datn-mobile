import 'package:AIPrimary/features/home/data/models/at_risk_student_model.dart';
import 'package:AIPrimary/features/home/data/models/calendar_event_model.dart';
import 'package:AIPrimary/features/home/data/models/class_at_risk_students_model.dart';
import 'package:AIPrimary/features/home/data/models/class_performance_model.dart';
import 'package:AIPrimary/features/home/data/models/grading_queue_model.dart';
import 'package:AIPrimary/features/home/data/models/item_analysis_model.dart';
import 'package:AIPrimary/features/home/data/models/recent_activity_model.dart';
import 'package:AIPrimary/features/home/data/models/student_performance_model.dart';
import 'package:AIPrimary/features/home/data/models/teacher_summary_model.dart';
import 'package:AIPrimary/features/home/data/source/analytics_remote_source.dart';
import 'package:AIPrimary/features/home/domain/repositories/analytics_repository.dart';

/// Implementation of AnalyticsRepository using remote API source.
class AnalyticsRepositoryImpl implements AnalyticsRepository {
  final AnalyticsRemoteSource _remoteSource;

  AnalyticsRepositoryImpl(this._remoteSource);

  @override
  Future<TeacherSummaryModel> getTeacherSummary() async {
    final response = await _remoteSource.getTeacherSummary();
    if (response.data == null) {
      throw Exception('Failed to load teacher summary');
    }
    return response.data!;
  }

  @override
  Future<List<CalendarEventModel>> getTeacherCalendar({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final response = await _remoteSource.getTeacherCalendar(
      startDate: startDate?.toLocal().toIso8601String().split('T').first,
      endDate: endDate?.toLocal().toIso8601String().split('T').first,
    );
    return response.data ?? [];
  }

  @override
  Future<List<GradingQueueItemModel>> getGradingQueue({
    int page = 0,
    int size = 50,
  }) async {
    final response = await _remoteSource.getGradingQueue(
      page: page,
      size: size,
    );
    return response.data ?? [];
  }

  @override
  Future<List<AtRiskStudentModel>> getAtRiskStudents(String classId) async {
    final response = await _remoteSource.getAtRiskStudents(classId);
    return response.data ?? [];
  }

  @override
  Future<List<ClassAtRiskStudentsModel>> getAllClassesAtRiskStudents() async {
    final response = await _remoteSource.getAllClassesAtRiskStudents();
    return response.data ?? [];
  }

  @override
  Future<List<RecentActivityModel>> getRecentActivity({int limit = 20}) async {
    final response = await _remoteSource.getRecentActivity(limit: limit);
    return response.data ?? [];
  }

  @override
  Future<ClassPerformanceModel> getClassPerformance(String classId) async {
    final response = await _remoteSource.getClassPerformance(classId);
    if (response.data == null) {
      throw Exception('Failed to load class performance');
    }
    return response.data!;
  }

  @override
  Future<ItemAnalysisModel> getItemAnalysis(String assignmentId) async {
    final response = await _remoteSource.getItemAnalysis(assignmentId);
    if (response.data == null) {
      throw Exception('Failed to load item analysis');
    }
    return response.data!;
  }

  @override
  Future<List<CalendarEventModel>> getStudentCalendar({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final response = await _remoteSource.getStudentCalendar(
      startDate: startDate?.toIso8601String(),
      endDate: endDate?.toIso8601String(),
    );
    return response.data ?? [];
  }

  @override
  Future<StudentPerformanceModel> getStudentPerformance() async {
    final response = await _remoteSource.getStudentPerformance();
    if (response.data == null) {
      throw Exception('Failed to load student performance');
    }
    return response.data!;
  }
}
