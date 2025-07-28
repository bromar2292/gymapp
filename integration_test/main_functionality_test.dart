import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:gymapp/main.dart';
import 'test_helpers.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Gym App Core Functionality', () {
    testWidgets('can create and save a workout', (WidgetTester tester) async {
      await tester.pumpWidget(const ProviderScope(child: MyApp()));
      await tester.pumpAndSettle();

      expect(find.text('Record Workout'), findsOneWidget);
      expect(find.text('Add Set'), findsOneWidget);
      
      await IntegrationTestHelpers.addWorkoutSet(tester);
      
      expect(find.text('Set 1'), findsOneWidget);
      
      await IntegrationTestHelpers.fillWorkoutData(
        tester,
        weight: '135',
        reps: '8',
      );
      
      expect(find.text('Save Workout'), findsOneWidget);
      await IntegrationTestHelpers.saveWorkout(tester);
      
      expect(find.text('Add Set'), findsOneWidget);
    });

    testWidgets('can navigate to workouts screen', (WidgetTester tester) async {
      await tester.pumpWidget(const ProviderScope(child: MyApp()));
      await tester.pumpAndSettle();

      expect(find.text('Record Workout'), findsOneWidget);
      
      await IntegrationTestHelpers.goToWorkouts(tester);
      expect(find.text('Workout List'), findsOneWidget);
      
      await IntegrationTestHelpers.goToHome(tester);
      expect(find.text('Record Workout'), findsOneWidget);
    });

    testWidgets('can create multiple workout sets', (WidgetTester tester) async {
      await tester.pumpWidget(const ProviderScope(child: MyApp()));
      await tester.pumpAndSettle();

      await IntegrationTestHelpers.addWorkoutSet(tester);
      expect(find.text('Set 1'), findsOneWidget);
      
      await IntegrationTestHelpers.addWorkoutSet(tester);
      expect(find.text('Set 2'), findsOneWidget);
      
      await IntegrationTestHelpers.addWorkoutSet(tester);
      expect(find.text('Set 3'), findsOneWidget);
      
      expect(find.text('Set 1'), findsOneWidget);
      expect(find.text('Set 2'), findsOneWidget);
      expect(find.text('Set 3'), findsOneWidget);
    });

    testWidgets('save button behavior is correct', (WidgetTester tester) async {
      await tester.pumpWidget(const ProviderScope(child: MyApp()));
      await tester.pumpAndSettle();

      expect(find.text('Save Workout'), findsNothing);
      
      await IntegrationTestHelpers.addWorkoutSet(tester);
      expect(find.text('Save Workout'), findsOneWidget);
      
      await IntegrationTestHelpers.saveWorkout(tester);
      
      expect(find.text('Save Workout'), findsNothing);
    });
  });
}