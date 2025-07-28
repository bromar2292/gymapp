import 'package:gymapp/data/database_helper.dart';
import 'package:gymapp/data/workout_repository.dart';
import 'package:gymapp/models/workout.dart';
import 'package:gymapp/models/workout_set.dart';
import 'package:gymapp/utils/constants.dart';

class WorkoutRepositoryImpl implements WorkoutRepository {
  WorkoutRepositoryImpl(this._databaseHelper);

  final DatabaseHelper _databaseHelper;

  @override
  Future<List<Workout>> getAllWorkouts() async {
    final database = await _databaseHelper.database;
    
    final workoutMaps = await database.query(
      AppConstants.workoutsTable,
      orderBy: 'created_at DESC',
    );

    final workouts = <Workout>[];
    
    for (final workoutMap in workoutMaps) {
      final workout = await _buildWorkoutFromDatabaseMap(workoutMap);
      workouts.add(workout);
    }

    return workouts;
  }

  @override
  Future<Workout?> getWorkoutById(String workoutId) async {
    final database = await _databaseHelper.database;
    
    final workoutMaps = await database.query(
      AppConstants.workoutsTable,
      where: 'id = ?',
      whereArgs: [workoutId],
      limit: 1,
    );

    if (workoutMaps.isEmpty) {
      return null;
    }

    return _buildWorkoutFromDatabaseMap(workoutMaps.first);
  }

  @override
  Future<void> saveWorkout(Workout workout) async {
    final database = await _databaseHelper.database;
    
    await database.transaction((transaction) async {
      await transaction.insert(
        AppConstants.workoutsTable,
        _buildWorkoutDatabaseMap(workout),
      );

      for (final workoutSet in workout.sets) {
        await transaction.insert(
          AppConstants.workoutSetsTable,
          _buildWorkoutSetDatabaseMap(workoutSet, workout.id),
        );
      }
    });
  }

  @override
  Future<void> updateWorkout(Workout workout) async {
    final database = await _databaseHelper.database;
    
    await database.transaction((transaction) async {
      await transaction.update(
        AppConstants.workoutsTable,
        {
          'updated_at': workout.updatedAt.toIso8601String(),
          'notes': workout.notes,
        },
        where: 'id = ?',
        whereArgs: [workout.id],
      );

      await transaction.delete(
        AppConstants.workoutSetsTable,
        where: 'workout_id = ?',
        whereArgs: [workout.id],
      );

      for (final workoutSet in workout.sets) {
        await transaction.insert(
          AppConstants.workoutSetsTable,
          _buildWorkoutSetDatabaseMap(workoutSet, workout.id),
        );
      }
    });
  }

  @override
  Future<void> deleteWorkout(String workoutId) async {
    final database = await _databaseHelper.database;
    
    await database.delete(
      AppConstants.workoutsTable,
      where: 'id = ?',
      whereArgs: [workoutId],
    );
  }

  Future<Workout> _buildWorkoutFromDatabaseMap(Map<String, dynamic> workoutMap) async {
    final database = await _databaseHelper.database;
    
    final setMaps = await database.query(
      AppConstants.workoutSetsTable,
      where: 'workout_id = ?',
      whereArgs: [workoutMap['id']],
      orderBy: 'set_order ASC',
    );

    final workoutSets = setMaps.map(_buildWorkoutSetFromDatabaseMap).toList();

    return Workout.fromJson({
      ...workoutMap,
      'createdAt': workoutMap['created_at'],
      'updatedAt': workoutMap['updated_at'],
      'sets': workoutSets.map((set) => set.toJson()).toList(),
    });
  }

  WorkoutSet _buildWorkoutSetFromDatabaseMap(Map<String, dynamic> setMap) {
    return WorkoutSet.fromJson({
      ...setMap,
      'weightKg': setMap['weight_kg'],
      'order': setMap['set_order'],
    });
  }

  Map<String, dynamic> _buildWorkoutDatabaseMap(Workout workout) {
    return {
      'id': workout.id,
      'created_at': workout.createdAt.toIso8601String(),
      'updated_at': workout.updatedAt.toIso8601String(),
      'notes': workout.notes,
    };
  }

  Map<String, dynamic> _buildWorkoutSetDatabaseMap(WorkoutSet workoutSet, String workoutId) {
    return {
      'id': workoutSet.id,
      'workout_id': workoutId,
      'exercise': workoutSet.exercise.name,
      'weight_kg': workoutSet.weightKg,
      'reps': workoutSet.reps,
      'set_order': workoutSet.order,
    };
  }
}
