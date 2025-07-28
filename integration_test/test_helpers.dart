import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class IntegrationTestHelpers {
  static Future<void> goToWorkouts(WidgetTester tester) async {
    final workoutsTab = find.text('Workouts');
    await tester.tap(workoutsTab);
    await tester.pumpAndSettle();
  }

  static Future<void> goToHome(WidgetTester tester) async {
    final homeTab = find.text('Home');
    await tester.tap(homeTab);
    await tester.pumpAndSettle();
  }

  static Future<void> addWorkoutSet(WidgetTester tester) async {
    final addButton = find.text('Add Set');
    await tester.tap(addButton);
    await tester.pumpAndSettle();
  }

  static Future<void> fillWorkoutData(
    WidgetTester tester, {
    String weight = '100',
    String reps = '10',
  }) async {
    final textFields = find.byType(TextField);
    
    if (textFields.evaluate().isNotEmpty) {
      await tester.enterText(textFields.first, weight);
      await tester.pumpAndSettle();
      
      if (textFields.evaluate().length > 1) {
        await tester.enterText(textFields.at(1), reps);
        await tester.pumpAndSettle();
      }
    }
  }

  static Future<void> saveWorkout(WidgetTester tester) async {
    final saveButton = find.text('Save Workout');
    await tester.tap(saveButton);
    await tester.pumpAndSettle();
  }

  static Future<void> deleteFirstWorkout(WidgetTester tester) async {
    final deleteButtons = find.byIcon(Icons.delete);
    if (deleteButtons.evaluate().isNotEmpty) {
      await tester.tap(deleteButtons.first);
      await tester.pumpAndSettle();
    }
  }

  static void verifyWorkoutExists({
    required String exercise,
    required String weight,
    required String reps,
  }) {
    expect(find.text(exercise), findsOneWidget);
    expect(find.text('$weight lbs × $reps'), findsOneWidget);
  }

  static void verifyEmptyState() {
    expect(find.text('No workouts yet'), findsOneWidget);
  }
}