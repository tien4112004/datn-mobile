import 'package:json_annotation/json_annotation.dart';

part 'media_response.g.dart';

@JsonSerializable()
class MediaResponse {
  final int id;
  final String cdnUrl;
  final String extension;
  final String mediaType;
  final int? fileSize;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  MediaResponse({
    required this.id,
    required this.cdnUrl,
    required this.extension,
    required this.mediaType,
    this.fileSize,
    this.createdAt,
    this.updatedAt,
  });

  MediaResponse copyWith({
    int? id,
    String? cdnUrl,
    String? extension,
    String? mediaType,
    int? fileSize,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return MediaResponse(
      id: id ?? this.id,
      cdnUrl: cdnUrl ?? this.cdnUrl,
      extension: extension ?? this.extension,
      mediaType: mediaType ?? this.mediaType,
      fileSize: fileSize,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  factory MediaResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>;
    return MediaResponse(
      id: data['id'],
      cdnUrl: data['cdnUrl'],
      extension: data['extension'],
      mediaType: data['mediaType'],
      fileSize: data['fileSize'] != null ? data['fileSize'] as int? : null,
      createdAt: data['createdAt'] == null
          ? null
          : DateTime.parse(data['createdAt'] as String),
      updatedAt: data['updatedAt'] == null
          ? null
          : DateTime.parse(data['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() => _$MediaResponseToJson(this);
}
