import 'package:json_annotation/json_annotation.dart';

part 'award.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class Award {
  const Award({
    this.id,
    required this.title,
    required this.recognition,
    required this.description,
    this.image = '',
    required this.awardedAt,
  });

  factory Award.fromJson(Map<String, dynamic> json) => _$AwardFromJson(json);

  @JsonKey(includeToJson: false)
  final String? id;
  final String title;
  final String recognition;
  final String description;
  @JsonKey(defaultValue: '')
  final String image;
  @JsonKey(toJson: _dateToJson)
  final DateTime awardedAt;

  static String _dateToJson(DateTime date) =>
      date.toIso8601String().split('T').first;

  Map<String, dynamic> toJson() => _$AwardToJson(this);
}
