import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:gymapp/models/converters/exercise_converter.dart';
import 'package:gymapp/models/exercise.dart';

part 'workout_set.freezed.dart';
part 'workout_set.g.dart';

@freezed
class WorkoutSet with _$WorkoutSet {
  const factory WorkoutSet({
    required String id,
    @ExerciseConverter() required Exercise exercise,
    required double weightKg,
    required int reps,
    required int order,
  }) = _WorkoutSet;

  const WorkoutSet._();

  factory WorkoutSet.fromJson(Map<String, dynamic> json) =>
      _$WorkoutSetFromJson(json);

  double get volume => weightKg * reps;
}
