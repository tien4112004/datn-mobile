import 'package:AIPrimary/features/home/data/models/at_risk_student_model.dart';
import 'package:AIPrimary/features/home/data/models/calendar_event_model.dart';
import 'package:AIPrimary/features/home/data/models/class_at_risk_students_model.dart';
import 'package:AIPrimary/features/home/data/models/class_performance_model.dart';
import 'package:AIPrimary/features/home/data/models/grading_queue_model.dart';
import 'package:AIPrimary/features/home/data/models/item_analysis_model.dart';
import 'package:AIPrimary/features/home/data/models/recent_activity_model.dart';
import 'package:AIPrimary/features/home/data/models/student_performance_model.dart';
import 'package:AIPrimary/features/home/data/models/teacher_summary_model.dart';
import 'package:AIPrimary/features/home/data/repositories/analytics_repository_impl.dart';
import 'package:AIPrimary/features/home/data/source/analytics_remote_source.dart';
import 'package:AIPrimary/features/home/domain/repositories/analytics_repository.dart';
import 'package:AIPrimary/shared/api_client/dio/dio_client_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provider for AnalyticsRemoteSource
final analyticsRemoteSourceProvider = Provider<AnalyticsRemoteSource>((ref) {
  return AnalyticsRemoteSource(ref.watch(dioPod));
});

/// Provider for AnalyticsRepository
final analyticsRepositoryProvider = Provider<AnalyticsRepository>((ref) {
  return AnalyticsRepositoryImpl(ref.watch(analyticsRemoteSourceProvider));
});

/// Provider for Teacher Summary
final teacherSummaryProvider = FutureProvider.autoDispose<TeacherSummaryModel>((
  ref,
) async {
  final repository = ref.watch(analyticsRepositoryProvider);
  return repository.getTeacherSummary();
});

/// Provider for Teacher Calendar (current month)
final teacherCalendarProvider =
    FutureProvider.autoDispose<List<CalendarEventModel>>((ref) async {
      final repository = ref.watch(analyticsRepositoryProvider);
      final now = DateTime.now();
      final startDate = DateTime(now.year, now.month, 1);
      final endDate = DateTime(now.year, now.month + 1, 0, 23, 59, 59);
      return repository.getTeacherCalendar(
        startDate: startDate,
        endDate: endDate,
      );
    });

/// Provider for Grading Queue
final gradingQueueProvider =
    FutureProvider.autoDispose<List<GradingQueueItemModel>>((ref) async {
      final repository = ref.watch(analyticsRepositoryProvider);
      return repository.getGradingQueue(size: 10);
    });

/// Provider for At-Risk Students (by class ID)
final atRiskStudentsProvider = FutureProvider.family
    .autoDispose<List<AtRiskStudentModel>, String>((ref, classId) async {
      final repository = ref.watch(analyticsRepositoryProvider);
      return repository.getAtRiskStudents(classId);
    });

/// Provider for All Classes with At-Risk Students
final allClassesAtRiskStudentsProvider =
    FutureProvider.autoDispose<List<ClassAtRiskStudentsModel>>((ref) async {
      final repository = ref.watch(analyticsRepositoryProvider);
      return repository.getAllClassesAtRiskStudents();
    });

/// Provider for Recent Activity
final recentActivityProvider =
    FutureProvider.autoDispose<List<RecentActivityModel>>((ref) async {
      final repository = ref.watch(analyticsRepositoryProvider);
      return repository.getRecentActivity(limit: 10);
    });

/// Provider for Class Performance
final classPerformanceProvider = FutureProvider.autoDispose
    .family<ClassPerformanceModel, String>((ref, classId) async {
      final repository = ref.watch(analyticsRepositoryProvider);
      return repository.getClassPerformance(classId);
    });

/// Provider for Item Analysis
final itemAnalysisProvider = FutureProvider.autoDispose
    .family<ItemAnalysisModel, String>((ref, assignmentId) async {
      final repository = ref.watch(analyticsRepositoryProvider);
      return repository.getItemAnalysis(assignmentId);
    });

/// Provider for Student Calendar (current month)
final studentCalendarProvider =
    FutureProvider.autoDispose<List<CalendarEventModel>>((ref) async {
      final repository = ref.watch(analyticsRepositoryProvider);
      final now = DateTime.now();
      final startDate = DateTime(now.year, now.month, 1);
      final endDate = DateTime(now.year, now.month + 1, 0, 23, 59, 59);
      return repository.getStudentCalendar(
        startDate: startDate,
        endDate: endDate,
      );
    });

/// Provider for Student Performance
final studentPerformanceProvider =
    FutureProvider.autoDispose<StudentPerformanceModel>((ref) async {
      final repository = ref.watch(analyticsRepositoryProvider);
      return repository.getStudentPerformance();
    });
