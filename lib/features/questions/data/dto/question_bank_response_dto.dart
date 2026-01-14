import 'package:json_annotation/json_annotation.dart';
import 'package:datn_mobile/features/questions/data/dto/question_bank_item_dto.dart';

part 'question_bank_response_dto.g.dart';

/// Pagination metadata.
@JsonSerializable()
class PaginationDto {
  @JsonKey(name: 'currentPage')
  final int page;
  @JsonKey(name: 'pageSize')
  final int pageSize;
  @JsonKey(name: 'totalItems')
  final int total;
  @JsonKey(name: 'totalPages')
  final int totalPages;

  PaginationDto({
    required this.page,
    required this.pageSize,
    required this.total,
    required this.totalPages,
  });

  factory PaginationDto.fromJson(Map<String, dynamic> json) =>
      _$PaginationDtoFromJson(json);

  Map<String, dynamic> toJson() => _$PaginationDtoToJson(this);
}

/// Response DTO for paginated question bank list.
@JsonSerializable()
class QuestionBankResponseDto {
  final bool success;
  final int code;
  final String timestamp;
  final List<QuestionBankItemDto> data;
  final PaginationDto pagination;

  QuestionBankResponseDto({
    required this.success,
    required this.code,
    required this.timestamp,
    required this.data,
    required this.pagination,
  });

  factory QuestionBankResponseDto.fromJson(Map<String, dynamic> json) =>
      _$QuestionBankResponseDtoFromJson(json);

  Map<String, dynamic> toJson() => _$QuestionBankResponseDtoToJson(this);
}
