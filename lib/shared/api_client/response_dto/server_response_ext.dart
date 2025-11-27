part of 'server_reponse_dto.dart';

/// Validates and extracts data from ServerResponseDto
/// Throws APIException if response indicates failure
extension ServerResponseDtoExtension<T> on ServerResponseDto<T> {
  T validateAndExtractData(String operation) {
    if (!success || data == null) {
      throw APIException(
        code: code,
        errorCode: errorCode,
        errorMessage: detail ?? 'Operation failed: $operation',
      );
    }
    return data!;
  }
}
