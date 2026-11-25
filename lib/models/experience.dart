import 'package:json_annotation/json_annotation.dart';

part 'experience.g.dart';

const experienceCategories = {
  'internship': 'Internship',
  'research': 'Research',
  'volunteer': 'Volunteer',
  'part-time': 'Part-Time',
  'full-time': 'Full-Time',
  'freelance': 'Freelance',
};

@JsonSerializable(fieldRename: FieldRename.snake)
class Experience {
  const Experience({
    this.id,
    required this.title,
    required this.description,
    required this.category,
    this.categoryDisplay,
    required this.startedAt,
    this.endedAt,
  });

  factory Experience.fromJson(Map<String, dynamic> json) =>
      _$ExperienceFromJson(json);

  @JsonKey(includeToJson: false)
  final String? id;
  final String title;
  final String description;
  final String category;
  @JsonKey(includeToJson: false)
  final String? categoryDisplay;
  final DateTime startedAt;
  final DateTime? endedAt;

  String get categoryLabel =>
      categoryDisplay ?? experienceCategories[category] ?? category;

  Map<String, dynamic> toJson() => _$ExperienceToJson(this);
}
