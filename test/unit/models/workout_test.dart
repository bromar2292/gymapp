import 'package:flutter_test/flutter_test.dart';
import 'package:gymapp/models/exercise.dart';
import 'package:gymapp/models/workout.dart';
import 'package:gymapp/models/workout_set.dart';

void main() {
  group('Workout', () {
    late DateTime testDate;
    late List<WorkoutSet> testSets;
    late Workout workout;

    setUp(() {
      testDate = DateTime(2024, 1, 15, 10, 30);
      testSets = [
        const WorkoutSet(
          id: 'set-1',
          exercise: Exercise.benchPress,
          weightKg: 50.0,
          reps: 10,
          order: 0,
        ),
        const WorkoutSet(
          id: 'set-2',
          exercise: Exercise.benchPress,
          weightKg: 55.0,
          reps: 8,
          order: 1,
        ),
        const WorkoutSet(
          id: 'set-3',
          exercise: Exercise.deadlift,
          weightKg: 80.0,
          reps: 5,
          order: 2,
        ),
      ];

      workout = Workout(
        id: 'workout-1',
        createdAt: testDate,
        updatedAt: testDate,
        sets: testSets,
        notes: 'Great workout!',
      );
    });

    group('construction', () {
      test('should create workout with required fields', () {
        expect(workout.id, 'workout-1');
        expect(workout.createdAt, testDate);
        expect(workout.updatedAt, testDate);
        expect(workout.sets, testSets);
        expect(workout.notes, 'Great workout!');
      });

      test('should create workout without notes', () {
        final workoutWithoutNotes = Workout(
          id: 'workout-2',
          createdAt: testDate,
          updatedAt: testDate,
          sets: testSets,
        );

        expect(workoutWithoutNotes.notes, isNull);
      });

      test('should create workout with empty sets', () {
        final emptyWorkout = Workout(
          id: 'workout-3',
          createdAt: testDate,
          updatedAt: testDate,
          sets: const [],
        );

        expect(emptyWorkout.sets, isEmpty);
        expect(emptyWorkout.totalSets, 0);
        expect(emptyWorkout.totalVolume, 0.0);
      });
    });

    group('totalVolume calculation', () {
      test('should calculate total volume correctly', () {
        expect(workout.totalVolume, 1340.0);
      });

      test('should return 0 for empty workout', () {
        final emptyWorkout = workout.copyWith(sets: []);
        expect(emptyWorkout.totalVolume, 0.0);
      });

      test('should handle single set', () {
        final singleSetWorkout = workout.copyWith(sets: [testSets[0]]);
        expect(singleSetWorkout.totalVolume, 500.0);
      });

      test('should handle decimal weights', () {
        final decimalSets = [
          const WorkoutSet(
            id: 'set-1',
            exercise: Exercise.benchPress,
            weightKg: 22.5,
            reps: 10,
            order: 0,
          ),
          const WorkoutSet(
            id: 'set-2',
            exercise: Exercise.squat,
            weightKg: 42.5,
            reps: 8,
            order: 1,
          ),
        ];

        final decimalWorkout = workout.copyWith(sets: decimalSets);
        expect(decimalWorkout.totalVolume, 565.0);
      });
    });

    group('totalSets calculation', () {
      test('should return correct number of sets', () {
        expect(workout.totalSets, 3);
      });

      test('should return 0 for empty workout', () {
        final emptyWorkout = workout.copyWith(sets: []);
        expect(emptyWorkout.totalSets, 0);
      });

      test('should handle single set', () {
        final singleSetWorkout = workout.copyWith(sets: [testSets[0]]);
        expect(singleSetWorkout.totalSets, 1);
      });
    });

    group('summary generation', () {
      test('should generate correct summary with multiple exercises', () {
        expect(workout.summary, '3 sets • Bench Press, Deadlift');
      });

      test('should generate summary with single exercise', () {
        final singleExerciseSets = [
          testSets[0],
          testSets[1],
        ];
        final singleExerciseWorkout = workout.copyWith(sets: singleExerciseSets);

        expect(singleExerciseWorkout.summary, '2 sets • Bench Press');
      });

      test('should return "Empty workout" for no sets', () {
        final emptyWorkout = workout.copyWith(sets: []);
        expect(emptyWorkout.summary, 'Empty workout');
      });

      test('should handle duplicate exercises correctly', () {
        final duplicateSets = [
          testSets[0],
          testSets[1],
          testSets[2],
          const WorkoutSet(
            id: 'set-4',
            exercise: Exercise.benchPress,
            weightKg: 60.0,
            reps: 6,
            order: 3,
          ),
        ];

        final duplicateWorkout = workout.copyWith(sets: duplicateSets);
        expect(duplicateWorkout.summary, '4 sets • Bench Press, Deadlift');
      });

    });

   

    group('equality', () {
      test('should be equal when all fields match', () {
        final sameWorkout = Workout(
          id: 'workout-1',
          createdAt: testDate,
          updatedAt: testDate,
          sets: testSets,
          notes: 'Great workout!',
        );

        expect(workout, equals(sameWorkout));
        expect(workout.hashCode, equals(sameWorkout.hashCode));
      });

      test('should not be equal when fields differ', () {
        final differentWorkout = workout.copyWith(notes: 'Different notes');
        expect(workout, isNot(equals(differentWorkout)));
      });
    });

    group('JSON serialization', () {
      test('should serialize to JSON correctly', () {
        final json = workout.toJson();

        expect(json['id'], 'workout-1');
        expect(json['createdAt'], testDate.toIso8601String());
        expect(json['updatedAt'], testDate.toIso8601String());
        expect(json['notes'], 'Great workout!');
        expect(json['sets'], isA<List<dynamic>>());
        expect((json['sets'] as List<dynamic>).length, 3);
      });

      test('should deserialize from JSON correctly', () {
        final json = {
          'id': 'workout-2',
          'createdAt': '2024-01-16T15:30:00.000Z',
          'updatedAt': '2024-01-16T15:35:00.000Z',
          'sets': testSets.map((s) => s.toJson()).toList(),
          'notes': 'Test workout',
        };

        final deserializedWorkout = Workout.fromJson(json);

        expect(deserializedWorkout.id, 'workout-2');
        expect(deserializedWorkout.createdAt, DateTime.parse('2024-01-16T15:30:00.000Z'));
        expect(deserializedWorkout.updatedAt, DateTime.parse('2024-01-16T15:35:00.000Z'));
        expect(deserializedWorkout.notes, 'Test workout');
        expect(deserializedWorkout.sets.length, 3);
      });


      test('should handle null notes in JSON', () {
        final jsonWithoutNotes = {
          'id': 'workout-3',
          'createdAt': testDate.toIso8601String(),
          'updatedAt': testDate.toIso8601String(),
          'sets': <Map<String, dynamic>>[],
        };

        final workoutWithoutNotes = Workout.fromJson(jsonWithoutNotes);
        expect(workoutWithoutNotes.notes, isNull);
      });
    });

    group('edge cases', () {
      test('should handle very long notes', () {
        final longNotes = 'A' * 1000;
        final workoutWithLongNotes = workout.copyWith(notes: longNotes);

        expect(workoutWithLongNotes.notes, longNotes);
        expect(workoutWithLongNotes.notes!.length, 1000);
      });

      test('should handle dates far in the past', () {
        final pastDate = DateTime(1900, 1, 1);
        final pastWorkout = workout.copyWith(createdAt: pastDate);

        expect(pastWorkout.createdAt, pastDate);
      });

      test('should handle dates far in the future', () {
        final futureDate = DateTime(2100, 12, 31);
        final futureWorkout = workout.copyWith(updatedAt: futureDate);

        expect(futureWorkout.updatedAt, futureDate);
      });

      test('should handle large number of sets', () {
        final manySets = List.generate(
          100,
          (index) => WorkoutSet(
            id: 'set-$index',
            exercise: Exercise.values[index % Exercise.values.length],
            weightKg: 50.0,
            reps: 10,
            order: index,
          ),
        );

        final bigWorkout = workout.copyWith(sets: manySets);
        expect(bigWorkout.totalSets, 100);
        expect(bigWorkout.totalVolume, 50000.0);
      });
    });
  });
}