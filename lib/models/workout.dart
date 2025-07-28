import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:gymapp/models/workout_set.dart';

part 'workout.freezed.dart';
part 'workout.g.dart';

@freezed
class Workout with _$Workout {
  const factory Workout({
    required String id,
    required DateTime createdAt,
    required DateTime updatedAt,
    required List<WorkoutSet> sets,
    String? notes,
  }) = _Workout;

  const Workout._();

  factory Workout.fromJson(Map<String, dynamic> json) =>
      _$WorkoutFromJson(json);

  double get totalVolume => 
      sets.fold(0, (totalVolume, currentSet) => totalVolume + currentSet.volume);

  int get totalSets => sets.length;

  String get summary {
    if (sets.isEmpty) {
      return 'Empty workout';
    }
    
    final uniqueExercises = sets
        .map((workoutSet) => workoutSet.exercise.displayName)
        .toSet()
        .join(', ');
    
    return '$totalSets sets • $uniqueExercises';
  }
}
