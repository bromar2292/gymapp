import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymapp/models/exercise.dart';
import 'package:gymapp/models/workout.dart';
import 'package:gymapp/models/workout_set.dart';
import 'package:gymapp/providers/workout_state.dart';

Exercise _getExercise(WorkoutSet set) => set.exercise;
String _getDisplayName(Exercise exercise) => exercise.displayName;

class TestHelpers {
  TestHelpers._();

  static WorkoutSet createWorkoutSet({
    String? id,
    Exercise? exercise,
    double? weightKg,
    int? reps,
    int? order,
  }) {
    return WorkoutSet(
      id: id ?? 'test-set-${DateTime.now().millisecondsSinceEpoch}',
      exercise: exercise ?? Exercise.benchPress,
      weightKg: weightKg ?? 50.0,
      reps: reps ?? 10,
      order: order ?? 0,
    );
  }

  static Workout createWorkout({
    String? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<WorkoutSet>? sets,
    String? notes,
  }) {
    final now = DateTime.now();
    return Workout(
      id: id ?? 'test-workout-${now.millisecondsSinceEpoch}',
      createdAt: createdAt ?? now,
      updatedAt: updatedAt ?? now,
      sets: sets ?? [createWorkoutSet()],
      notes: notes,
    );
  }

  static List<WorkoutSet> createWorkoutSets({int count = 3}) {
    return List.generate(count, (index) {
      return createWorkoutSet(
        id: 'set-$index',
        exercise: Exercise.values[index % Exercise.values.length],
        weightKg: 50.0 + (index * 5),
        reps: 10 - index,
        order: index,
      );
    });
  }

  static Workout createComprehensiveWorkout() {
    final sets = [
      createWorkoutSet(
        id: 'bench-1',
        exercise: Exercise.benchPress,
        weightKg: 40.0,
        reps: 10,
        order: 0,
      ),
      createWorkoutSet(
        id: 'bench-2',
        exercise: Exercise.benchPress,
        weightKg: 45.0,
        reps: 8,
        order: 1,
      ),
      createWorkoutSet(
        id: 'bench-3',
        exercise: Exercise.benchPress,
        weightKg: 50.0,
        reps: 6,
        order: 2,
      ),
      createWorkoutSet(
        id: 'deadlift-1',
        exercise: Exercise.deadlift,
        weightKg: 70.0,
        reps: 8,
        order: 3,
      ),
      createWorkoutSet(
        id: 'deadlift-2',
        exercise: Exercise.deadlift,
        weightKg: 75.0,
        reps: 6,
        order: 4,
      ),
    ];

    return createWorkout(
      id: 'comprehensive-workout',
      sets: sets,
      notes: 'Full upper and lower body workout',
    );
  }

  static Workout createEmptyWorkout() {
    return createWorkout(
      id: 'empty-workout',
      sets: [],
      notes: 'Rest day workout',
    );
  }

  static Matcher approximatelyEquals(double expected, {double precision = 0.001}) {
    return predicate<double>(
      (actual) => (actual - expected).abs() < precision,
      'approximately equals $expected (±$precision)',
    );
  }

  static Matcher containsAllExercises(List<Exercise> exercises) {
    return predicate<List<WorkoutSet>>(
      (sets) {
        final setExercises = sets.map(_getExercise).toSet();
        return exercises.every((exercise) => setExercises.contains(exercise));
      },
      'contains all exercises: ${exercises.map(_getDisplayName).join(', ')}',
    );
  }

  static Matcher hasVolumeInRange(double min, double max) {
    return predicate<Workout>(
      (workout) => workout.totalVolume >= min && workout.totalVolume <= max,
      'has volume between $min and $max',
    );
  }

  static Future<void> delay([Duration duration = const Duration(milliseconds: 10)]) {
    return Future.delayed(duration);
  }

  static Future<void> pumpAndSettle(WidgetTester tester, [Duration duration = const Duration(milliseconds: 100)]) async {
    await tester.pump();
    await tester.pump(duration);
  }

  static DateTime testDate([int year = 2024, int month = 1, int day = 15]) {
    return DateTime(year, month, day, 10, 30, 0);
  }

  static List<DateTime> createDateRange({
    required DateTime start,
    required int days,
  }) {
    return List.generate(
      days,
      (index) => start.add(Duration(days: index)),
    );
  }

  static bool hasProperSetOrdering(Workout workout) {
    for (int i = 0; i < workout.sets.length; i++) {
      if (workout.sets[i].order != i) {
        return false;
      }
    }
    return true;
  }

  static Map<Exercise, List<WorkoutSet>> groupSetsByExercise(List<WorkoutSet> sets) {
    final Map<Exercise, List<WorkoutSet>> grouped = {};
    for (final set in sets) {
      grouped.putIfAbsent(set.exercise, () => []).add(set);
    }
    return grouped;
  }

  static double calculateExpectedVolume(List<WorkoutSet> sets) {
    return sets.fold(0.0, (total, set) => total + set.volume);
  }

  static Map<String, dynamic> createWorkoutJson({
    String? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<Map<String, dynamic>>? sets,
    String? notes,
  }) {
    final now = DateTime.now();
    return {
      'id': id ?? 'test-workout',
      'createdAt': (createdAt ?? now).toIso8601String(),
      'updatedAt': (updatedAt ?? now).toIso8601String(),
      'sets': sets ?? [createWorkoutSetJson()],
      if (notes != null) 'notes': notes,
    };
  }

  static Map<String, dynamic> createWorkoutSetJson({
    String? id,
    String? exercise,
    double? weightKg,
    int? reps,
    int? order,
  }) {
    return {
      'id': id ?? 'test-set',
      'exercise': exercise ?? 'benchPress',
      'weightKg': weightKg ?? 50.0,
      'reps': reps ?? 10,
      'order': order ?? 0,
    };
  }
}

class TestWorkoutNotifier extends AsyncNotifier<WorkoutState> {
  final WorkoutState _initialState;
  final bool _isLoading;
  final String? _error;

  TestWorkoutNotifier(
    this._initialState, {
    bool isLoading = false,
    String? error,
  })  : _isLoading = isLoading,
        _error = error;

  @override
  Future<WorkoutState> build() async {
    if (_error != null) {
      throw Exception(_error);
    }
    
    if (_isLoading) {
      await Future.delayed(const Duration(seconds: 1));
    }
    
    return _initialState.copyWith(isLoading: _isLoading);
  }

  void addSet() {
    final newSet = TestHelpers.createWorkoutSet();
    final currentState = state.valueOrNull;
    if (currentState != null) {
      state = AsyncValue.data(
        currentState.copyWith(
          currentSets: [...currentState.currentSets, newSet],
        ),
      );
    }
  }

  void removeSet(String setId) {
    final currentState = state.valueOrNull;
    if (currentState != null) {
      state = AsyncValue.data(
        currentState.copyWith(
          currentSets: currentState.currentSets.where((set) => set.id != setId).toList(),
        ),
      );
    }
  }

  void updateSet(WorkoutSet set) {
    final currentState = state.valueOrNull;
    if (currentState != null) {
      final updatedSets = currentState.currentSets.map((s) => s.id == set.id ? set : s).toList();
      state = AsyncValue.data(
        currentState.copyWith(currentSets: updatedSets),
      );
    }
  }

  Future<void> saveCurrentWorkout() async {
  }

  void clearCurrentWorkout() {
    final currentState = state.valueOrNull;
    if (currentState != null) {
      state = AsyncValue.data(
        currentState.copyWith(
          currentSets: [],
          editingWorkoutId: null,
        ),
      );
    }
  }

  Future<void> loadWorkout(String workoutId) async {
  }
}