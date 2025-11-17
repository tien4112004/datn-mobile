import 'package:datn_mobile/shared/exception/base_exception.dart';
import 'package:json_annotation/json_annotation.dart';

part 'server_reponse_dto.g.dart';
part 'server_response_ext.dart';

@JsonSerializable(genericArgumentFactories: true, includeIfNull: false)
class ServerResponseDto<T> {
  @JsonKey(defaultValue: true)
  final bool success;

  @JsonKey(defaultValue: 200)
  final int code;

  @JsonKey(defaultValue: null)
  final String? timestamp;

  final T? data;
  final String? detail;
  final String? errorCode;
  final PaginationDto? pagination;

  const ServerResponseDto({
    this.success = true,
    this.code = 200,
    this.timestamp,
    this.data,
    this.detail,
    this.errorCode,
    this.pagination,
  });

  /// Factory constructor for JSON deserialization
  factory ServerResponseDto.fromJson(
    Map<String, dynamic> json,
    T Function(Object? json) fromJsonT,
  ) => _$ServerResponseDtoFromJson(json, fromJsonT);

  /// Method for JSON serialization
  Map<String, dynamic> toJson(Object? Function(T value) toJsonT) =>
      _$ServerResponseDtoToJson(this, toJsonT);

  /// Copy with method for immutability
  ServerResponseDto<T> copyWith({
    bool? success,
    int? code,
    String? timestamp,
    T? data,
    String? message,
    String? errorCode,
    PaginationDto? pagination,
  }) {
    return ServerResponseDto<T>(
      success: success ?? this.success,
      code: code ?? this.code,
      timestamp: timestamp ?? this.timestamp,
      data: data ?? this.data,
      detail: message ?? detail,
      errorCode: errorCode ?? this.errorCode,
      pagination: pagination ?? this.pagination,
    );
  }
}

/// Pagination DTO class
@JsonSerializable(includeIfNull: false)
class PaginationDto {
  final int? page;
  final int? size;
  final int? totalElements;
  final int? totalPages;

  const PaginationDto({
    this.page,
    this.size,
    this.totalElements,
    this.totalPages,
  });

  factory PaginationDto.fromJson(Map<String, dynamic> json) =>
      _$PaginationDtoFromJson(json);

  Map<String, dynamic> toJson() => _$PaginationDtoToJson(this);

  @override
  String toString() {
    return 'PaginationDto(page: $page, size: $size, totalElements: $totalElements, totalPages: $totalPages)';
  }
}
