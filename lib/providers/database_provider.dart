import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymapp/data/database_helper.dart';
import 'package:gymapp/data/workout_repository.dart';
import 'package:gymapp/data/workout_repository_impl.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'database_provider.g.dart';

@Riverpod(keepAlive: true)
DatabaseHelper databaseHelper(Ref ref) {
  return DatabaseHelper();
}

@Riverpod(keepAlive: true)
WorkoutRepository workoutRepository(Ref ref) {
  return WorkoutRepositoryImpl(ref.watch(databaseHelperProvider));
}

