import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gymapp/models/exercise.dart';
import 'package:gymapp/models/workout_set.dart';
import 'package:gymapp/widgets/exercise_dropdown.dart';
import 'package:gymapp/widgets/number_input.dart';
import 'package:gymapp/widgets/workout_set_card.dart';

import '../../helpers/test_helpers.dart';

void _addToUpdateHistory(List<WorkoutSet> history, WorkoutSet set) => history.add(set);

void main() {
  group('WorkoutSetCard Widget', () {
    late WorkoutSet testSet;
    late WorkoutSet? lastUpdatedSet;
    late bool removeCallbackCalled;

    setUp(() {
      testSet = TestHelpers.createWorkoutSet(
        id: 'test-set',
        exercise: Exercise.benchPress,
        weightKg: 50.0,
        reps: 10,
        order: 0,
      );
      lastUpdatedSet = null;
      removeCallbackCalled = false;
    });

    Widget createTestWidget({
      required WorkoutSet set,
      required int setNumber,
      required void Function(WorkoutSet) onUpdate,
      required VoidCallback onRemove,
    }) {
      return MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: WorkoutSetCard(
              currentSet: set,
              displaySetNumber: setNumber,
              onSetUpdate: onUpdate,
              onSetRemove: onRemove,
            ),
          ),
        ),
      );
    }

    group('display and layout', () {
      testWidgets('should display set number and exercise', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget(
          set: testSet,
          setNumber: 1,
          onUpdate: (set) => lastUpdatedSet = set,
          onRemove: () => removeCallbackCalled = true,
        ));

        expect(find.text('Set 1'), findsOneWidget);
        expect(find.text('Bench Press'), findsOneWidget);
        expect(find.text('Remove set'), findsOneWidget);
      });

      testWidgets('should display weight and reps correctly', (WidgetTester tester) async {
        final setWithDecimals = testSet.copyWith(weightKg: 22.5, reps: 8);

        await tester.pumpWidget(createTestWidget(
          set: setWithDecimals,
          setNumber: 2,
          onUpdate: (set) => lastUpdatedSet = set,
          onRemove: () => removeCallbackCalled = true,
        ));

        expect(find.text('Set 2'), findsOneWidget);
        expect(find.text('22.5'), findsOneWidget); // Weight
        expect(find.text('8'), findsOneWidget);    // Reps
      });

      testWidgets('should have proper card styling', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget(
          set: testSet,
          setNumber: 1,
          onUpdate: (set) => lastUpdatedSet = set,
          onRemove: () => removeCallbackCalled = true,
        ));

        final container = tester.widget<Container>(
          find.descendant(
            of: find.byType(WorkoutSetCard),
            matching: find.byType(Container),
          ).first,
        );

        final decoration = container.decoration! as BoxDecoration;
        expect(decoration.borderRadius, BorderRadius.circular(16));
        expect(container.padding, const EdgeInsets.all(12));
      });

      testWidgets('should contain required input widgets', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget(
          set: testSet,
          setNumber: 1,
          onUpdate: (set) => lastUpdatedSet = set,
          onRemove: () => removeCallbackCalled = true,
        ));

        expect(find.byType(ExerciseDropdown), findsOneWidget);
        expect(find.byType(NumberInput), findsNWidgets(2)); // Weight and Reps
        expect(find.byType(OutlinedButton), findsOneWidget); // Remove button
      });
    });

    group('exercise selection', () {
      testWidgets('should call onUpdate when exercise changes', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget(
          set: testSet,
          setNumber: 1,
          onUpdate: (set) => lastUpdatedSet = set,
          onRemove: () => removeCallbackCalled = true,
        ));

        // Act - Change exercise
        await tester.tap(find.byType(ExerciseDropdown));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Deadlift').last);
        await tester.pumpAndSettle();

        expect(lastUpdatedSet, isNotNull);
        expect(lastUpdatedSet!.exercise, Exercise.deadlift);
        expect(lastUpdatedSet!.id, testSet.id); // Other fields unchanged
        expect(lastUpdatedSet!.weightKg, testSet.weightKg);
        expect(lastUpdatedSet!.reps, testSet.reps);
      });

      testWidgets('should maintain other values when exercise changes', (WidgetTester tester) async {
        final customSet = testSet.copyWith(weightKg: 75.5, reps: 12);
        
        await tester.pumpWidget(createTestWidget(
          set: customSet,
          setNumber: 3,
          onUpdate: (set) => lastUpdatedSet = set,
          onRemove: () => removeCallbackCalled = true,
        ));

        // Act - Change exercise
        await tester.tap(find.byType(ExerciseDropdown));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Squat').last);
        await tester.pumpAndSettle();

        expect(lastUpdatedSet!.exercise, Exercise.squat);
        expect(lastUpdatedSet!.weightKg, 75.5); // Preserved
        expect(lastUpdatedSet!.reps, 12);       // Preserved
      });
    });

    group('weight input', () {
      testWidgets('should call onUpdate when weight changes via text input', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget(
          set: testSet,
          setNumber: 1,
          onUpdate: (set) => lastUpdatedSet = set,
          onRemove: () => removeCallbackCalled = true,
        ));

        // Act - Find weight input and change value
        final weightInputs = find.byType(NumberInput);
        expect(weightInputs, findsNWidgets(2));
        
        // First NumberInput should be weight (based on layout)
        final weightTextField = find.descendant(
          of: weightInputs.first,
          matching: find.byType(TextField),
        );
        
        await tester.enterText(weightTextField, '65.5');

        expect(lastUpdatedSet, isNotNull);
        expect(lastUpdatedSet!.weightKg, 65.5);
        expect(lastUpdatedSet!.exercise, testSet.exercise); // Unchanged
        expect(lastUpdatedSet!.reps, testSet.reps);         // Unchanged
      });

      testWidgets('should call onUpdate when weight changes via increment', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget(
          set: testSet,
          setNumber: 1,
          onUpdate: (set) => lastUpdatedSet = set,
          onRemove: () => removeCallbackCalled = true,
        ));

        // Act - Find weight input increment button specifically
        final weightInputs = find.ancestor(
          of: find.text('Weight (kg)'),
          matching: find.byType(NumberInput),
        );
        final weightIncrementButton = find.descendant(
          of: weightInputs,
          matching: find.byIcon(Icons.arrow_drop_up),
        );
        
        await tester.tap(weightIncrementButton);

        expect(lastUpdatedSet, isNotNull);
        expect(lastUpdatedSet!.weightKg, 51.0); // 50.0 + 1
      });
    });

    group('reps input', () {
      testWidgets('should call onUpdate when reps change via text input', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget(
          set: testSet,
          setNumber: 1,
          onUpdate: (set) => lastUpdatedSet = set,
          onRemove: () => removeCallbackCalled = true,
        ));

        // Act - Find reps input and change value
        final repsInputs = find.byType(NumberInput);
        expect(repsInputs, findsNWidgets(2));
        
        // Second NumberInput should be reps (based on layout)
        final repsTextField = find.descendant(
          of: repsInputs.last,
          matching: find.byType(TextField),
        );
        
        await tester.enterText(repsTextField, '15');

        expect(lastUpdatedSet, isNotNull);
        expect(lastUpdatedSet!.reps, 15);
        expect(lastUpdatedSet!.exercise, testSet.exercise); // Unchanged
        expect(lastUpdatedSet!.weightKg, testSet.weightKg); // Unchanged
      });

      testWidgets('should call onUpdate when reps change via decrement', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget(
          set: testSet,
          setNumber: 1,
          onUpdate: (set) => lastUpdatedSet = set,
          onRemove: () => removeCallbackCalled = true,
        ));

        // Act - Find reps input decrement button specifically
        final repsInputs = find.ancestor(
          of: find.text('Reps'),
          matching: find.byType(NumberInput),
        );
        final repsDecrementButton = find.descendant(
          of: repsInputs,
          matching: find.byIcon(Icons.arrow_drop_down),
        );
        
        await tester.tap(repsDecrementButton);

        expect(lastUpdatedSet, isNotNull);
        expect(lastUpdatedSet!.reps, 9); // 10 - 1
      });

      testWidgets('should handle reps as integer even with decimal input', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget(
          set: testSet,
          setNumber: 1,
          onUpdate: (set) => lastUpdatedSet = set,
          onRemove: () => removeCallbackCalled = true,
        ));

        // Act - Enter decimal value for reps
        final repsTextField = find.descendant(
          of: find.byType(NumberInput).last,
          matching: find.byType(TextField),
        );
        
        await tester.enterText(repsTextField, '12.7');

        expect(lastUpdatedSet, isNotNull);
        expect(lastUpdatedSet!.reps, 12); // Should be converted to int
      });
    });

    group('remove functionality', () {
      testWidgets('should call onRemove when remove button is tapped', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget(
          set: testSet,
          setNumber: 1,
          onUpdate: (set) => lastUpdatedSet = set,
          onRemove: () => removeCallbackCalled = true,
        ));

        await tester.tap(find.byType(OutlinedButton));

        expect(removeCallbackCalled, isTrue);
      });

      testWidgets('should display remove button with correct text', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget(
          set: testSet,
          setNumber: 5,
          onUpdate: (set) => lastUpdatedSet = set,
          onRemove: () => removeCallbackCalled = true,
        ));

        final removeButton = find.byType(OutlinedButton);
        expect(removeButton, findsOneWidget);
        expect(find.descendant(
          of: removeButton,
          matching: find.text('Remove set'),
        ), findsOneWidget);
      });
    });

    group('set number display', () {
      testWidgets('should display correct set number', (WidgetTester tester) async {
        // Test various set numbers
        for (final int setNumber in [1, 5, 10, 99]) {
          await tester.pumpWidget(createTestWidget(
            set: testSet,
            setNumber: setNumber,
            onUpdate: (set) => lastUpdatedSet = set,
            onRemove: () => removeCallbackCalled = true,
          ));

          expect(find.text('Set $setNumber'), findsOneWidget);
        }
      });
    });

    group('value updates and state management', () {
      testWidgets('should reflect external value changes', (WidgetTester tester) async {
        WorkoutSet currentSet = testSet;

        await tester.pumpWidget(createTestWidget(
          set: currentSet,
          setNumber: 1,
          onUpdate: (set) => currentSet = set,
          onRemove: () => removeCallbackCalled = true,
        ));

        expect(find.text('50.0'), findsOneWidget); // Initial weight
        expect(find.text('10'), findsOneWidget);   // Initial reps

        // Act - Update set externally and rebuild
        currentSet = currentSet.copyWith(weightKg: 80.0, reps: 6);
        
        await tester.pumpWidget(createTestWidget(
          set: currentSet,
          setNumber: 1,
          onUpdate: (set) => currentSet = set,
          onRemove: () => removeCallbackCalled = true,
        ));

        expect(find.text('80.0'), findsOneWidget); // Updated weight
        expect(find.text('6'), findsOneWidget);    // Updated reps
        expect(find.text('50.0'), findsNothing);   // Old weight gone
        expect(find.text('10'), findsNothing);     // Old reps gone
      });

      testWidgets('should handle rapid value changes', (WidgetTester tester) async {
        final updateHistory = <WorkoutSet>[];
        WorkoutSet currentSet = testSet;
        
        Widget buildWidget() => createTestWidget(
          set: currentSet,
          setNumber: 1,
          onUpdate: (set) {
            currentSet = set;
            _addToUpdateHistory(updateHistory, set);
          },
          onRemove: () => removeCallbackCalled = true,
        );
        
        await tester.pumpWidget(buildWidget());

        // Act - Make rapid changes to weight (find weight increment button specifically)
        final weightInputs = find.ancestor(
          of: find.text('Weight (kg)'),
          matching: find.byType(NumberInput),
        );
        final weightIncrementButton = find.descendant(
          of: weightInputs,
          matching: find.byIcon(Icons.arrow_drop_up),
        );
        
        // Increment weight multiple times with proper state updates
        await tester.tap(weightIncrementButton);
        await tester.pumpWidget(buildWidget());
        await tester.tap(weightIncrementButton);
        await tester.pumpWidget(buildWidget());
        await tester.tap(weightIncrementButton);
        await tester.pumpWidget(buildWidget());

        expect(updateHistory, hasLength(3));
        expect(updateHistory[0].weightKg, 51.0);
        expect(updateHistory[1].weightKg, 52.0);
        expect(updateHistory[2].weightKg, 53.0);
      });
    });

    group('edge cases', () {
      testWidgets('should handle zero values', (WidgetTester tester) async {
        final zeroSet = testSet.copyWith(weightKg: 0.0, reps: 0);

        await tester.pumpWidget(createTestWidget(
          set: zeroSet,
          setNumber: 1,
          onUpdate: (set) => lastUpdatedSet = set,
          onRemove: () => removeCallbackCalled = true,
        ));

        expect(find.text('0.0'), findsOneWidget);
        expect(find.text('0'), findsOneWidget);
      });

      testWidgets('should handle large values', (WidgetTester tester) async {
        final largeSet = testSet.copyWith(weightKg: 999.9, reps: 100);

        await tester.pumpWidget(createTestWidget(
          set: largeSet,
          setNumber: 99,
          onUpdate: (set) => lastUpdatedSet = set,
          onRemove: () => removeCallbackCalled = true,
        ));

        expect(find.text('Set 99'), findsOneWidget);
        expect(find.text('999.9'), findsOneWidget);
        expect(find.text('100'), findsOneWidget);
      });

      testWidgets('should work in constrained layout', (WidgetTester tester) async {
        await tester.pumpWidget(MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 300,
              height: 210,
              child: WorkoutSetCard(
                currentSet: testSet,
                displaySetNumber: 1,
                onSetUpdate: (set) => lastUpdatedSet = set,
                onSetRemove: () => removeCallbackCalled = true,
              ),
            ),
          ),
        ));

        // Assert - Should render without overflow
        expect(find.byType(WorkoutSetCard), findsOneWidget);
        expect(find.text('Set 1'), findsOneWidget);
        
        // Should still be functional
        await tester.tap(find.byType(OutlinedButton));
        expect(removeCallbackCalled, isTrue);
      });
    });

    group('accessibility', () {
      testWidgets('should be accessible via semantics', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget(
          set: testSet,
          setNumber: 1,
          onUpdate: (set) => lastUpdatedSet = set,
          onRemove: () => removeCallbackCalled = true,
        ));

        // Assert - All interactive elements should be findable
        expect(find.byType(ExerciseDropdown), findsOneWidget);
        expect(find.byType(NumberInput), findsNWidgets(2));
        expect(find.byType(OutlinedButton), findsOneWidget);

        // Should be able to interact with all elements
        await tester.tap(find.byType(ExerciseDropdown));
        await tester.pumpAndSettle();
        
        await tester.tap(find.text('Squat').last);
        await tester.pumpAndSettle();

        expect(lastUpdatedSet!.exercise, Exercise.squat);
      });
    });
  });
}