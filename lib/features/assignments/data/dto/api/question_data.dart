import 'package:json_annotation/json_annotation.dart';

part 'question_data.g.dart';

/// Polymorphic question data structures based on question type
/// From ASSIGNMENT_API_DOCS.md

// ============================================================================
// MULTIPLE_CHOICE Data
// ============================================================================

@JsonSerializable(fieldRename: FieldRename.none, includeIfNull: false)
class MultipleChoiceData {
  final String type; // Must be "MULTIPLE_CHOICE"
  final bool? shuffleOptions;
  final List<MultipleChoiceOption> options;

  const MultipleChoiceData({
    this.type = 'MULTIPLE_CHOICE',
    this.shuffleOptions,
    required this.options,
  });

  factory MultipleChoiceData.fromJson(Map<String, dynamic> json) =>
      _$MultipleChoiceDataFromJson(json);

  Map<String, dynamic> toJson() => _$MultipleChoiceDataToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.none, includeIfNull: false)
class MultipleChoiceOption {
  final String? id;
  final String text;
  final String? imageUrl;
  final bool isCorrect;

  const MultipleChoiceOption({
    this.id,
    required this.text,
    this.imageUrl,
    required this.isCorrect,
  });

  factory MultipleChoiceOption.fromJson(Map<String, dynamic> json) =>
      _$MultipleChoiceOptionFromJson(json);

  Map<String, dynamic> toJson() => _$MultipleChoiceOptionToJson(this);
}

// ============================================================================
// MATCHING Data
// ============================================================================

@JsonSerializable(fieldRename: FieldRename.none, includeIfNull: false)
class MatchingData {
  final String type; // Must be "MATCHING"
  final bool? shufflePairs;
  final List<MatchingPair> pairs;

  const MatchingData({
    this.type = 'MATCHING',
    this.shufflePairs,
    required this.pairs,
  });

  factory MatchingData.fromJson(Map<String, dynamic> json) =>
      _$MatchingDataFromJson(json);

  Map<String, dynamic> toJson() => _$MatchingDataToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.none, includeIfNull: false)
class MatchingPair {
  final String id;
  final String left;
  final String? leftImageUrl;
  final String right;
  final String? rightImageUrl;

  const MatchingPair({
    required this.id,
    required this.left,
    this.leftImageUrl,
    required this.right,
    this.rightImageUrl,
  });

  factory MatchingPair.fromJson(Map<String, dynamic> json) =>
      _$MatchingPairFromJson(json);

  Map<String, dynamic> toJson() => _$MatchingPairToJson(this);
}

// ============================================================================
// FILL_IN_BLANK Data
// ============================================================================

@JsonSerializable(fieldRename: FieldRename.none, includeIfNull: false)
class FillInBlankData {
  final String type; // Must be "FILL_IN_BLANK"
  final bool? caseSensitive;
  final List<BlankSegment> segments;

  const FillInBlankData({
    this.type = 'FILL_IN_BLANK',
    this.caseSensitive,
    required this.segments,
  });

  factory FillInBlankData.fromJson(Map<String, dynamic> json) =>
      _$FillInBlankDataFromJson(json);

  Map<String, dynamic> toJson() => _$FillInBlankDataToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.none, includeIfNull: false)
class BlankSegment {
  final String id;
  final String type; // TEXT or BLANK
  final String? content; // Text to display if type is TEXT
  final List<String>? acceptableAnswers; // Correct answers if type is BLANK

  const BlankSegment({
    required this.id,
    required this.type,
    this.content,
    this.acceptableAnswers,
  });

  factory BlankSegment.fromJson(Map<String, dynamic> json) =>
      _$BlankSegmentFromJson(json);

  Map<String, dynamic> toJson() => _$BlankSegmentToJson(this);
}

// ============================================================================
// OPEN_ENDED Data
// ============================================================================

@JsonSerializable(fieldRename: FieldRename.none, includeIfNull: false)
class OpenEndedData {
  final String type; // Must be "OPEN_ENDED"
  final String? expectedAnswer;
  final int? maxLength;

  const OpenEndedData({
    this.type = 'OPEN_ENDED',
    this.expectedAnswer,
    this.maxLength,
  });

  factory OpenEndedData.fromJson(Map<String, dynamic> json) =>
      _$OpenEndedDataFromJson(json);

  Map<String, dynamic> toJson() => _$OpenEndedDataToJson(this);
}
