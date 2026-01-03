/// Domain entity for tracking exam generation progress.
class GenerationProgressEntity {
  final int current;
  final int total;
  final String message;

  const GenerationProgressEntity({
    required this.current,
    required this.total,
    required this.message,
  });

  /// Calculate progress percentage (0-100).
  double get progressPercentage =>
      total > 0 ? (current / total * 100).clamp(0, 100) : 0;

  /// Check if generation is complete.
  bool get isComplete => current >= total;

  GenerationProgressEntity copyWith({
    int? current,
    int? total,
    String? message,
  }) {
    return GenerationProgressEntity(
      current: current ?? this.current,
      total: total ?? this.total,
      message: message ?? this.message,
    );
  }
}
