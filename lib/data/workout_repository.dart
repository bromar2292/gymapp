import 'package:gymapp/models/workout.dart';

abstract class WorkoutRepository {
  Future<List<Workout>> getAllWorkouts();
  Future<Workout?> getWorkoutById(String id);
  Future<void> saveWorkout(Workout workout);
  Future<void> updateWorkout(Workout workout);
  Future<void> deleteWorkout(String id);
}
