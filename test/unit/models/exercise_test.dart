import 'package:flutter_test/flutter_test.dart';
import 'package:gymapp/models/exercise.dart';

void main() {
  group('Exercise', () {
    test('should have correct display names', () {
      expect(Exercise.barbellRow.displayName, 'Barbell Row');
      expect(Exercise.benchPress.displayName, 'Bench Press');
      expect(Exercise.shoulerPress.displayName, 'Shoulder Press');
      expect(Exercise.deadlift.displayName, 'Deadlift');
      expect(Exercise.squat.displayName, 'Squat');
    });

    test('should have correct enum names', () {
      expect(Exercise.barbellRow.name, 'barbellRow');
      expect(Exercise.benchPress.name, 'benchPress');
      expect(Exercise.shoulerPress.name, 'shoulderPress');
      expect(Exercise.deadlift.name, 'deadlift');
      expect(Exercise.squat.name, 'squat');
    });

    group('fromString', () {
      test('should return correct exercise from valid string', () {
        expect(Exercise.fromString('barbellRow'), Exercise.barbellRow);
        expect(Exercise.fromString('benchPress'), Exercise.benchPress);
        expect(Exercise.fromString('shoulderPress'), Exercise.shoulerPress);
        expect(Exercise.fromString('deadlift'), Exercise.deadlift);
        expect(Exercise.fromString('squat'), Exercise.squat);
      });

      test('should throw ArgumentError for invalid string', () {
        expect(
          () => Exercise.fromString('invalidExercise'),
          throwsA(isA<ArgumentError>()),
        );
        expect(
          () => Exercise.fromString(''),
          throwsA(isA<ArgumentError>()),
        );
        expect(
          () => Exercise.fromString('BenchPress'),
          throwsA(isA<ArgumentError>()),
        );
      });

      test('should contain expected error message', () {
        expect(
          () => Exercise.fromString('invalidExercise'),
          throwsA(
            predicate((e) =>
                e is ArgumentError &&
                e.message == 'Invalid exercise: invalidExercise'),
          ),
        );
      });
    });

    test('should contain exactly 5 exercises', () {
      expect(Exercise.values.length, 5);
    });

    test('should maintain enum order', () {
      expect(Exercise.values[0], Exercise.barbellRow);
      expect(Exercise.values[1], Exercise.benchPress);
      expect(Exercise.values[2], Exercise.shoulerPress);
      expect(Exercise.values[3], Exercise.deadlift);
      expect(Exercise.values[4], Exercise.squat);
    });
  });
}