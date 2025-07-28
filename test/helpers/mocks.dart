import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sqflite/sqflite.dart';
import 'package:gymapp/data/database_helper.dart';
import 'package:gymapp/data/workout_repository.dart';
import 'package:gymapp/models/workout.dart';

Future<List<Workout>> _emptyWorkoutList(_) async => [];

class MockDatabase extends Mock implements Database {}

class MockDatabaseHelper extends Mock implements DatabaseHelper {}

class MockWorkoutRepository extends Mock implements WorkoutRepository {}

class MockBatch extends Mock implements Batch {}

class MockTransaction extends Mock implements Transaction {}

class MockSetup {
  MockSetup._();

  static MockDatabase setupMockDatabase() {
    final mockDb = MockDatabase();
    
    when(() => mockDb.query(any())).thenAnswer((_) async => []);
    when(() => mockDb.query(
      any(),
      where: any(named: 'where'),
      whereArgs: any(named: 'whereArgs'),
      orderBy: any(named: 'orderBy'),
      limit: any(named: 'limit'),
    )).thenAnswer((_) async => []);
    
    when(() => mockDb.insert(any(), any())).thenAnswer((_) async => 1);
    when(() => mockDb.update(
      any(),
      any(),
      where: any(named: 'where'),
      whereArgs: any(named: 'whereArgs'),
    )).thenAnswer((_) async => 1);
    
    when(() => mockDb.delete(
      any(),
      where: any(named: 'where'),
      whereArgs: any(named: 'whereArgs'),
    )).thenAnswer((_) async => 1);

    when(() => mockDb.transaction<void>(any())).thenAnswer((invocation) async {
      final callback = invocation.positionalArguments[0] as Future<void> Function(Transaction);
      final mockTransaction = MockTransaction();
      
      when(() => mockTransaction.insert(any(), any())).thenAnswer((_) async => 1);
      when(() => mockTransaction.update(any(), any(), where: any(named: 'where'), whereArgs: any(named: 'whereArgs'))).thenAnswer((_) async => 1);
      when(() => mockTransaction.delete(any(), where: any(named: 'where'), whereArgs: any(named: 'whereArgs'))).thenAnswer((_) async => 1);
      
      await callback(mockTransaction);
    });

    return mockDb;
  }

  static MockDatabaseHelper setupMockDatabaseHelper(MockDatabase mockDb) {
    final mockHelper = MockDatabaseHelper();
    when(() => mockHelper.database).thenAnswer((_) async => mockDb);
    return mockHelper;
  }

  static MockWorkoutRepository setupMockWorkoutRepository() {
    final mockRepo = MockWorkoutRepository();
    
    when(() => mockRepo.getAllWorkouts()).thenAnswer(_emptyWorkoutList);
    when(() => mockRepo.getWorkoutById(any())).thenAnswer((_) async => null);
    when(() => mockRepo.saveWorkout(any())).thenAnswer((_) async {});
    when(() => mockRepo.updateWorkout(any())).thenAnswer((_) async {});
    when(() => mockRepo.deleteWorkout(any())).thenAnswer((_) async {});
    
    return mockRepo;
  }

  static void setupMockRepositoryWithWorkouts(
    MockWorkoutRepository mockRepo,
    List<Workout> workouts,
  ) {
    when(() => mockRepo.getAllWorkouts()).thenAnswer((_) async => workouts);
    
    for (final workout in workouts) {
      when(() => mockRepo.getWorkoutById(workout.id))
          .thenAnswer((_) async => workout);
    }
  }

  static void setupMockRepositoryWithErrors(MockWorkoutRepository mockRepo) {
    when(() => mockRepo.getAllWorkouts())
        .thenThrow(Exception('Database error'));
    when(() => mockRepo.getWorkoutById(any()))
        .thenThrow(Exception('Database error'));
    when(() => mockRepo.saveWorkout(any()))
        .thenThrow(Exception('Save error'));
    when(() => mockRepo.updateWorkout(any()))
        .thenThrow(Exception('Update error'));
    when(() => mockRepo.deleteWorkout(any()))
        .thenThrow(Exception('Delete error'));
  }

  static void verifyNoMoreInteractionsAll(List<Mock> mocks) {
    for (final mock in mocks) {
      verifyNoMoreInteractions(mock);
    }
  }

  static void resetMocks(List<Mock> mocks) {
    for (final mock in mocks) {
      reset(mock);
    }
  }
}

class WorkoutMatchers {
  WorkoutMatchers._();

  static Matcher isWorkoutWith({
    String? id,
    int? setCount,
    double? totalVolume,
    String? notes,
  }) {
    return predicate<Workout>((workout) {
      if (id != null && workout.id != id) return false;
      if (setCount != null && workout.totalSets != setCount) return false;
      if (totalVolume != null && (workout.totalVolume - totalVolume).abs() > 0.01) return false;
      if (notes != null && workout.notes != notes) return false;
      return true;
    }, 'is workout with specified properties');
  }

  static Matcher containsWorkoutWithId(String workoutId) {
    return predicate<List<Workout>>(
      (workouts) => workouts.any((w) => w.id == workoutId),
      'contains workout with ID: $workoutId',
    );
  }

  static Matcher isSortedByCreationDate({bool descending = true}) {
    return predicate<List<Workout>>((workouts) {
      for (int i = 0; i < workouts.length - 1; i++) {
        final current = workouts[i].createdAt;
        final next = workouts[i + 1].createdAt;
        
        if (descending) {
          if (current.isBefore(next)) return false;
        } else {
          if (current.isAfter(next)) return false;
        }
      }
      return true;
    }, 'is sorted by creation date (${descending ? 'descending' : 'ascending'})');
  }
}

class VerificationHelpers {
  VerificationHelpers._();

  static void verifyWorkoutSaved(MockWorkoutRepository mockRepo, Workout workout) {
    verify(() => mockRepo.saveWorkout(
      any(that: predicate<Workout>((w) => w.id == workout.id)),
    )).called(1);
  }

  static void verifyWorkoutDeleted(MockWorkoutRepository mockRepo, String workoutId) {
    verify(() => mockRepo.deleteWorkout(workoutId)).called(1);
  }

  static void verifyWorkoutUpdated(MockWorkoutRepository mockRepo, String workoutId) {
    verify(() => mockRepo.updateWorkout(
      any(that: predicate<Workout>((w) => w.id == workoutId)),
    )).called(1);
  }

  static void verifyTransactionUsed(MockDatabase mockDb) {
    verify(() => mockDb.transaction(any())).called(1);
  }

  static void verifyDatabaseInsert(MockDatabase mockDb, String table) {
    verify(() => mockDb.insert(table, any())).called(greaterThan(0));
  }

  static void verifyDatabaseUpdate(MockDatabase mockDb, String table) {
    verify(() => mockDb.update(
      table,
      any(),
      where: any(named: 'where'),
      whereArgs: any(named: 'whereArgs'),
    )).called(1);
  }

  static void verifyDatabaseDelete(MockDatabase mockDb, String table) {
    verify(() => mockDb.delete(
      table,
      where: any(named: 'where'),
      whereArgs: any(named: 'whereArgs'),
    )).called(1);
  }

  static void verifyDatabaseQuery(MockDatabase mockDb, String table) {
    verify(() => mockDb.query(table, orderBy: any(named: 'orderBy')))
        .called(greaterThan(0));
  }
}