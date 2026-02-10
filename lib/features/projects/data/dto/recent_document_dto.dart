import 'package:AIPrimary/features/projects/domain/entity/recent_document.dart';
import 'package:json_annotation/json_annotation.dart';

part 'recent_document_dto.g.dart';

@JsonSerializable()
class RecentDocumentDto {
  final String id;
  final String documentId;
  final String documentType;
  final String title;
  final String? thumbnail;
  final DateTime lastVisited;

  RecentDocumentDto({
    required this.id,
    required this.documentId,
    required this.documentType,
    required this.title,
    this.thumbnail,
    required this.lastVisited,
  });

  factory RecentDocumentDto.fromJson(Map<String, dynamic> json) =>
      _$RecentDocumentDtoFromJson(json);

  Map<String, dynamic> toJson() => _$RecentDocumentDtoToJson(this);
}

extension RecentDocumentMapper on RecentDocumentDto {
  RecentDocument toEntity() {
    return RecentDocument(
      id: id,
      documentId: documentId,
      documentType: documentType,
      title: title,
      thumbnail: thumbnail,
      lastVisited: lastVisited.toLocal(),
    );
  }
}

extension RecentDocumentDtoMapper on RecentDocument {
  RecentDocumentDto toDto() {
    return RecentDocumentDto(
      id: id,
      documentId: documentId,
      documentType: documentType,
      title: title,
      thumbnail: thumbnail,
      lastVisited: lastVisited,
    );
  }
}
