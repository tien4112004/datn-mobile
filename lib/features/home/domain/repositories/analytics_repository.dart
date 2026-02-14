import 'package:AIPrimary/features/home/data/models/at_risk_student_model.dart';
import 'package:AIPrimary/features/home/data/models/calendar_event_model.dart';
import 'package:AIPrimary/features/home/data/models/class_at_risk_students_model.dart';
import 'package:AIPrimary/features/home/data/models/class_performance_model.dart';
import 'package:AIPrimary/features/home/data/models/grading_queue_model.dart';
import 'package:AIPrimary/features/home/data/models/item_analysis_model.dart';
import 'package:AIPrimary/features/home/data/models/recent_activity_model.dart';
import 'package:AIPrimary/features/home/data/models/student_performance_model.dart';
import 'package:AIPrimary/features/home/data/models/teacher_summary_model.dart';

/// Repository interface for analytics data
abstract class AnalyticsRepository {
  /// Get teacher summary metrics
  Future<TeacherSummaryModel> getTeacherSummary();

  /// Get teacher calendar events
  Future<List<CalendarEventModel>> getTeacherCalendar({
    DateTime? startDate,
    DateTime? endDate,
  });

  /// Get grading queue
  Future<List<GradingQueueItemModel>> getGradingQueue({
    int page = 0,
    int size = 50,
  });

  /// Get at-risk students for a specific class
  Future<List<AtRiskStudentModel>> getAtRiskStudents(String classId);

  /// Get all classes with their at-risk students
  Future<List<ClassAtRiskStudentsModel>> getAllClassesAtRiskStudents();

  /// Get recent activity
  Future<List<RecentActivityModel>> getRecentActivity({int limit = 20});

  /// Get class performance
  Future<ClassPerformanceModel> getClassPerformance(String classId);

  /// Get item analysis for assignment
  Future<ItemAnalysisModel> getItemAnalysis(String assignmentId);

  /// Get student calendar events
  Future<List<CalendarEventModel>> getStudentCalendar({
    DateTime? startDate,
    DateTime? endDate,
  });

  /// Get student performance
  Future<StudentPerformanceModel> getStudentPerformance();

  /// Get specific student performance by ID (for teachers)
  Future<StudentPerformanceModel> getStudentPerformanceById(String studentId);
}
