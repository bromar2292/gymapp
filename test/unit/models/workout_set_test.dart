import 'package:flutter_test/flutter_test.dart';
import 'package:gymapp/models/exercise.dart';
import 'package:gymapp/models/workout_set.dart';

void main() {
  group('WorkoutSet', () {
    late WorkoutSet workoutSet;

    setUp(() {
      workoutSet = const WorkoutSet(
        id: 'set-1',
        exercise: Exercise.benchPress,
        weightKg: 50.0,
        reps: 10,
        order: 0,
      );
    });

    group('construction', () {
      test('should create workout set with required fields', () {
        expect(workoutSet.id, 'set-1');
        expect(workoutSet.exercise, Exercise.benchPress);
        expect(workoutSet.weightKg, 50.0);
        expect(workoutSet.reps, 10);
        expect(workoutSet.order, 0);
      });

      test('should allow creation with different exercises', () {
        final squatSet = workoutSet.copyWith(exercise: Exercise.squat);
        expect(squatSet.exercise, Exercise.squat);
        expect(squatSet.id, workoutSet.id); // Other fields unchanged
      });

      test('should allow decimal weights', () {
        final decimalWeightSet = workoutSet.copyWith(weightKg: 42.5);
        expect(decimalWeightSet.weightKg, 42.5);
      });
    });

    group('volume calculation', () {
      test('should calculate volume correctly', () {
        expect(workoutSet.volume, 500.0); // 50.0 * 10
      });

      test('should calculate volume with decimal weight', () {
        final decimalSet = workoutSet.copyWith(weightKg: 22.5, reps: 8);
        expect(decimalSet.volume, 180.0); // 22.5 * 8
      });

      test('should handle zero weight', () {
        final zeroWeightSet = workoutSet.copyWith(weightKg: 0.0);
        expect(zeroWeightSet.volume, 0.0);
      });

      test('should handle zero reps', () {
        final zeroRepsSet = workoutSet.copyWith(reps: 0);
        expect(zeroRepsSet.volume, 0.0);
      });

      test('should handle large numbers', () {
        final heavySet = workoutSet.copyWith(weightKg: 300.0, reps: 1);
        expect(heavySet.volume, 300.0);
      });
    });

    group('equality', () {
      test('should be equal when all fields match', () {
        final sameSet = const WorkoutSet(
          id: 'set-1',
          exercise: Exercise.benchPress,
          weightKg: 50.0,
          reps: 10,
          order: 0,
        );

        expect(workoutSet, equals(sameSet));
        expect(workoutSet.hashCode, equals(sameSet.hashCode));
      });

      test('should not be equal when fields differ', () {
        final differentSet = workoutSet.copyWith(weightKg: 60.0);
        expect(workoutSet, isNot(equals(differentSet)));
      });
    });

    group('JSON serialization', () {
      test('should serialize to JSON correctly', () {
        final json = workoutSet.toJson();

        expect(json['id'], 'set-1');
        expect(json['exercise'], 'benchPress');
        expect(json['weightKg'], 50.0);
        expect(json['reps'], 10);
        expect(json['order'], 0);
      });

      test('should deserialize from JSON correctly', () {
        final json = {
          'id': 'set-2',
          'exercise': 'deadlift',
          'weightKg': 80.0,
          'reps': 5,
          'order': 1,
        };

        final set = WorkoutSet.fromJson(json);

        expect(set.id, 'set-2');
        expect(set.exercise, Exercise.deadlift);
        expect(set.weightKg, 80.0);
        expect(set.reps, 5);
        expect(set.order, 1);
      });

      test('should round-trip serialize/deserialize', () {
        final json = workoutSet.toJson();
        final deserializedSet = WorkoutSet.fromJson(json);

        expect(deserializedSet, equals(workoutSet));
      });
    });

    group('edge cases', () {
      test('should handle minimum values', () {
        final minSet = const WorkoutSet(
          id: '',
          exercise: Exercise.barbellRow,
          weightKg: 0.0,
          reps: 0,
          order: 0,
        );

        expect(minSet.volume, 0.0);
        expect(minSet.id, '');
      });

      test('should handle maximum realistic values', () {
        final maxSet = const WorkoutSet(
          id: 'max-set',
          exercise: Exercise.deadlift,
          weightKg: 999.9,
          reps: 999,
          order: 999,
        );

        expect(maxSet.volume, 999.9 * 999);
        expect(maxSet.weightKg, 999.9);
        expect(maxSet.reps, 999);
      });
    });
  });
}
