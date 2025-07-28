import 'package:gymapp/models/exercise.dart';
import 'package:gymapp/models/workout.dart';
import 'package:gymapp/models/workout_set.dart';
import 'package:gymapp/providers/database_provider.dart';
import 'package:gymapp/providers/workout_state.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';

part 'workout_notifier.g.dart';

@riverpod
class WorkoutNotifier extends _$WorkoutNotifier {
  final _uuidGenerator = const Uuid();

  @override
  Future<WorkoutState> build() async {
    await _loadAllWorkoutsFromDatabase();
    return WorkoutState.initial();
  }

  Future<void> _loadAllWorkoutsFromDatabase() async {
    state = const AsyncValue.loading();
    
    try {
      final workoutRepository = ref.read(workoutRepositoryProvider);
      final allWorkouts = await workoutRepository.getAllWorkouts();
      
      state = AsyncValue.data(
        state.valueOrNull?.copyWith(
          workouts: allWorkouts,
          isLoading: false,
        ) ?? WorkoutState.initial().copyWith(workouts: allWorkouts),
      );
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  void addSet() {
    final currentState = state.valueOrNull;
    if (currentState == null) {
      return;
    }

    final newWorkoutSet = WorkoutSet(
      id: _uuidGenerator.v4(),
      exercise: Exercise.benchPress,
      weightKg: 40,
      reps: 10,
      order: currentState.currentSets.length,
    );

    state = AsyncValue.data(
      currentState.copyWith(
        currentSets: [...currentState.currentSets, newWorkoutSet],
      ),
    );
  }

  void updateSet(int setIndex, WorkoutSet updatedSet) {
    final currentState = state.valueOrNull;
    if (currentState == null) {
      return;
    }

    final modifiedSets = [...currentState.currentSets];
    modifiedSets[setIndex] = updatedSet;

    state = AsyncValue.data(
      currentState.copyWith(currentSets: modifiedSets),
    );
  }

  void removeSet(int setIndex) {
    final currentState = state.valueOrNull;
    if (currentState == null) {
      return;
    }

    final modifiedSets = [...currentState.currentSets]..removeAt(setIndex);
    
    for (var i = 0; i < modifiedSets.length; i++) {
      modifiedSets[i] = modifiedSets[i].copyWith(order: i);
    }

    state = AsyncValue.data(
      currentState.copyWith(currentSets: modifiedSets),
    );
  }

  Future<void> saveCurrentWorkout() async {
    final currentState = state.valueOrNull;
    if (currentState == null || currentState.currentSets.isEmpty) {
      return;
    }

    if (currentState.editingWorkoutId != null) {
      await _updateExistingWorkout(currentState.editingWorkoutId!);
    } else {
      await _createAndSaveNewWorkout();
    }
  }

  Future<void> _createAndSaveNewWorkout() async {
    final currentState = state.valueOrNull;
    if (currentState == null || currentState.currentSets.isEmpty) {
      return;
    }

    state = AsyncValue.data(currentState.copyWith(isLoading: true));

    try {
      final newWorkout = Workout(
        id: _uuidGenerator.v4(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        sets: currentState.currentSets,
      );

      final workoutRepository = ref.read(workoutRepositoryProvider);
      await workoutRepository.saveWorkout(newWorkout);

      state = AsyncValue.data(
        currentState.copyWith(
          workouts: [newWorkout, ...currentState.workouts],
          currentSets: [],
          isLoading: false,
          editingWorkoutId: null,
        ),
      );
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> deleteWorkout(String workoutId) async {
    final currentState = state.valueOrNull;
    if (currentState == null) {
      return;
    }

    try {
      final workoutRepository = ref.read(workoutRepositoryProvider);
      await workoutRepository.deleteWorkout(workoutId);

      final remainingWorkouts = currentState.workouts
          .where((workout) => workout.id != workoutId)
          .toList();

      state = AsyncValue.data(
        currentState.copyWith(workouts: remainingWorkouts),
      );
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> loadWorkoutForEdit(String workoutId) async {
    final currentState = state.valueOrNull;
    if (currentState == null) {
      return;
    }

    final workoutToEdit = currentState.workouts.firstWhere(
      (workout) => workout.id == workoutId,
    );
    
    state = AsyncValue.data(
      currentState.copyWith(
        currentSets: workoutToEdit.sets,
        editingWorkoutId: workoutId,
      ),
    );
  }

  Future<void> _updateExistingWorkout(String workoutId) async {
    final currentState = state.valueOrNull;
    if (currentState == null || currentState.currentSets.isEmpty) {
      return;
    }

    state = AsyncValue.data(currentState.copyWith(isLoading: true));

    try {
      final existingWorkout = currentState.workouts.firstWhere(
        (workout) => workout.id == workoutId,
      );
      
      final updatedWorkout = existingWorkout.copyWith(
        updatedAt: DateTime.now(),
        sets: currentState.currentSets,
      );

      final workoutRepository = ref.read(workoutRepositoryProvider);
      await workoutRepository.updateWorkout(updatedWorkout);

      final updatedWorkoutsList = currentState.workouts
          .map((workout) => workout.id == workoutId ? updatedWorkout : workout)
          .toList();

      state = AsyncValue.data(
        currentState.copyWith(
          workouts: updatedWorkoutsList,
          currentSets: [],
          isLoading: false,
          editingWorkoutId: null,
        ),
      );
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  void clearCurrentWorkout() {
    final currentState = state.valueOrNull;
    if (currentState == null) {
      return;
    }

    state = AsyncValue.data(
      currentState.copyWith(
        currentSets: [],
        editingWorkoutId: null,
      ),
    );
  }
}