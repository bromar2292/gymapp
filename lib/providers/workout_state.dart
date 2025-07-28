import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:gymapp/models/workout.dart';
import 'package:gymapp/models/workout_set.dart';

part 'workout_state.freezed.dart';

@freezed
class WorkoutState with _$WorkoutState {
  const factory WorkoutState({
    required List<Workout> workouts,
    required List<WorkoutSet> currentSets,
    required bool isLoading,
    String? editingWorkoutId,
    String? error,
  }) = _WorkoutState;

  factory WorkoutState.initial() => const WorkoutState(
        workouts: [],
        currentSets: [],
        isLoading: false,
      );
}