class PinPostRequestDto {
  final bool pinned;

  PinPostRequestDto({required this.pinned});

  factory PinPostRequestDto.fromJson(Map<String, dynamic> json) {
    return PinPostRequestDto(pinned: json['pinned']);
  }

  Map<String, dynamic> toJson() {
    return {'pinned': pinned};
  }
}
