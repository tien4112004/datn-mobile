import 'package:json_annotation/json_annotation.dart';
import '../../domain/entity/statistics_entity.dart';

part 'statistics_dto.g.dart';

/// Score distribution DTO with hyphenated keys
@JsonSerializable()
class ScoreDistributionDto {
  @JsonKey(name: 'below-70', defaultValue: 0)
  final int below70;

  @JsonKey(name: '70-79', defaultValue: 0)
  final int range70to79;

  @JsonKey(name: '80-89', defaultValue: 0)
  final int range80to89;

  @JsonKey(name: '90-100', defaultValue: 0)
  final int range90to100;

  const ScoreDistributionDto({
    this.below70 = 0,
    this.range70to79 = 0,
    this.range80to89 = 0,
    this.range90to100 = 0,
  });

  factory ScoreDistributionDto.fromJson(Map<String, dynamic> json) =>
      _$ScoreDistributionDtoFromJson(json);

  Map<String, dynamic> toJson() => _$ScoreDistributionDtoToJson(this);

  /// Convert to map for entity
  Map<String, int> toMap() {
    return {
      'below-70': below70,
      '70-79': range70to79,
      '80-89': range80to89,
      '90-100': range90to100,
    };
  }
}

/// Submission statistics response DTO
@JsonSerializable()
class SubmissionStatisticsResponseDto {
  final int totalSubmissions;
  final int gradedCount;
  final int pendingCount;
  final int inProgressCount;
  final double? averageScore;
  final double? highestScore;
  final double? lowestScore;
  final ScoreDistributionDto? scoreDistribution;

  const SubmissionStatisticsResponseDto({
    required this.totalSubmissions,
    required this.gradedCount,
    required this.pendingCount,
    required this.inProgressCount,
    this.averageScore,
    this.highestScore,
    this.lowestScore,
    this.scoreDistribution,
  });

  factory SubmissionStatisticsResponseDto.fromJson(Map<String, dynamic> json) =>
      _$SubmissionStatisticsResponseDtoFromJson(json);

  Map<String, dynamic> toJson() =>
      _$SubmissionStatisticsResponseDtoToJson(this);
}

/// Extension for DTO to Entity conversion
extension SubmissionStatisticsResponseDtoToEntity
    on SubmissionStatisticsResponseDto {
  SubmissionStatisticsEntity toEntity() {
    return SubmissionStatisticsEntity(
      totalSubmissions: totalSubmissions,
      gradedCount: gradedCount,
      pendingCount: pendingCount,
      inProgressCount: inProgressCount,
      averageScore: averageScore,
      highestScore: highestScore,
      lowestScore: lowestScore,
      scoreDistribution: scoreDistribution?.toMap() ?? {},
    );
  }
}
