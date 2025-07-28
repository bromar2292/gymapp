import 'package:gymapp/models/exercise.dart';
import 'package:json_annotation/json_annotation.dart';

class ExerciseConverter implements JsonConverter<Exercise, String> {
  const ExerciseConverter();

  @override
  Exercise fromJson(String json) => Exercise.fromString(json);

  @override
  String toJson(Exercise exercise) => exercise.name;
}
