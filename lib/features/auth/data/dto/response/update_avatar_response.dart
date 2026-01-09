import 'package:json_annotation/json_annotation.dart';

part 'update_avatar_response.g.dart';

@JsonSerializable()
class UpdateAvatarResponse {
  final String avatarUrl;

  UpdateAvatarResponse({required this.avatarUrl});

  factory UpdateAvatarResponse.fromJson(Map<String, dynamic> json) =>
      _$UpdateAvatarResponseFromJson(json);

  Map<String, dynamic> toJson() => _$UpdateAvatarResponseToJson(this);
}
