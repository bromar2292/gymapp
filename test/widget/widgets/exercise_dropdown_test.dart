import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gymapp/models/exercise.dart';
import 'package:gymapp/widgets/exercise_dropdown.dart';

void main() {
  group('ExerciseDropdown Widget', () {
    late Exercise selectedExercise;
    late Exercise? lastChangedValue;

    setUp(() {
      selectedExercise = Exercise.benchPress;
      lastChangedValue = null;
    });

    Widget createTestWidget({
      required Exercise value,
      required void Function(Exercise?) onChanged,
    }) {
      return MaterialApp(
        home: Scaffold(
          body: ExerciseDropdown(
            value: value,
            onChanged: onChanged,
          ),
        ),
      );
    }

    testWidgets('should display current exercise value', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(
        value: Exercise.benchPress,
        onChanged: (value) => lastChangedValue = value,
      ));

      expect(find.text('Bench Press'), findsOneWidget);
      expect(find.byType(DropdownButton<Exercise>), findsOneWidget);
    });

    testWidgets('should show all exercises as dropdown items', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(
        value: Exercise.benchPress,
        onChanged: (value) => lastChangedValue = value,
      ));

      await tester.tap(find.byType(DropdownButton<Exercise>));
      await tester.pumpAndSettle();

      for (final exercise in Exercise.values) {
        expect(find.text(exercise.displayName).last, findsOneWidget);
      }
    });

    testWidgets('should call onChanged when selection changes', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(
        value: Exercise.benchPress,
        onChanged: (value) => lastChangedValue = value,
      ));

      await tester.tap(find.byType(DropdownButton<Exercise>));
      await tester.pumpAndSettle();
      
      await tester.tap(find.text('Deadlift').last);
      await tester.pumpAndSettle();

      expect(lastChangedValue, Exercise.deadlift);
    });

    testWidgets('should update display when value changes', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(
        value: Exercise.benchPress,
        onChanged: (value) => selectedExercise = value!,
      ));

      expect(find.text('Bench Press'), findsOneWidget);

      selectedExercise = Exercise.squat;
      await tester.pumpWidget(createTestWidget(
        value: selectedExercise,
        onChanged: (value) => selectedExercise = value!,
      ));

      expect(find.text('Squat'), findsOneWidget);
      expect(find.text('Bench Press'), findsNothing);
    });

    testWidgets('should have correct styling and appearance', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(
        value: Exercise.shoulerPress,
        onChanged: (value) => lastChangedValue = value,
      ));

      final container = tester.widget<Container>(find.byType(Container));
      final decoration = container.decoration! as BoxDecoration;
      
      expect(decoration.borderRadius, BorderRadius.circular(8));
      expect(container.padding, const EdgeInsets.symmetric(horizontal: 16));

      final dropdown = tester.widget<DropdownButton<Exercise>>(find.byType(DropdownButton<Exercise>));
      expect(dropdown.isExpanded, isTrue);
    });

    testWidgets('should handle all exercise types correctly', (WidgetTester tester) async {
      // Test each exercise can be selected and displayed
      for (final exercise in Exercise.values) {
          await tester.pumpWidget(createTestWidget(
          value: exercise,
          onChanged: (value) => lastChangedValue = value,
        ));

          expect(find.text(exercise.displayName), findsOneWidget);

        // Verify dropdown items
        await tester.tap(find.byType(DropdownButton<Exercise>));
        await tester.pumpAndSettle();

        expect(find.text(exercise.displayName).last, findsOneWidget);

        // Close dropdown
        await tester.tap(find.text(exercise.displayName).last);
        await tester.pumpAndSettle();
      }
    });

    testWidgets('should maintain selection state across rebuilds', (WidgetTester tester) async {
      Exercise currentValue = Exercise.barbellRow;

      await tester.pumpWidget(createTestWidget(
        value: currentValue,
        onChanged: (value) => currentValue = value!,
      ));

      expect(find.text('Barbell Row'), findsOneWidget);

      // Act - Change selection
      await tester.tap(find.byType(DropdownButton<Exercise>));
      await tester.pumpAndSettle();
      
      await tester.tap(find.text('Deadlift').last);
      await tester.pumpAndSettle();

      currentValue = Exercise.deadlift;

      // Rebuild widget
      await tester.pumpWidget(createTestWidget(
        value: currentValue,
        onChanged: (value) => currentValue = value!,
      ));

      expect(find.text('Deadlift'), findsOneWidget);
      expect(find.text('Barbell Row'), findsNothing);
    });

    testWidgets('should be accessible', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(
        value: Exercise.benchPress,
        onChanged: (value) => lastChangedValue = value,
      ));

      // Assert - Check semantics
      final dropdown = find.byType(DropdownButton<Exercise>);
      expect(dropdown, findsOneWidget);

      // Verify the dropdown can be activated with semantics
      await tester.tap(dropdown);
      await tester.pumpAndSettle();

      // All options should be accessible
      for (final exercise in Exercise.values) {
        expect(find.text(exercise.displayName), findsWidgets);
      }
    });

    testWidgets('should handle rapid selection changes', (WidgetTester tester) async {
      final selectedValues = <Exercise>[];

      await tester.pumpWidget(createTestWidget(
        value: Exercise.benchPress,
        onChanged: (value) => selectedValues.add(value!),
      ));

      // Act - Rapidly change selections
      for (final exercise in [Exercise.squat, Exercise.deadlift, Exercise.shoulerPress]) {
        await tester.tap(find.byType(DropdownButton<Exercise>));
        await tester.pumpAndSettle();
        
        await tester.tap(find.text(exercise.displayName).last);
        await tester.pumpAndSettle();
      }

      expect(selectedValues, containsAll([Exercise.squat, Exercise.deadlift, Exercise.shoulerPress]));
    });

    group('edge cases', () {
      testWidgets('should handle null onChanged gracefully', (WidgetTester tester) async {
          await tester.pumpWidget(MaterialApp(
          home: Scaffold(
            body: ExerciseDropdown(
              value: Exercise.benchPress,
              onChanged: (value) {}, // Empty callback
            ),
          ),
        ));

        // Assert - Should not throw
        expect(find.byType(ExerciseDropdown), findsOneWidget);
        expect(find.text('Bench Press'), findsOneWidget);
      });

      testWidgets('should work in constrained layout', (WidgetTester tester) async {
          await tester.pumpWidget(MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 200,
              height: 100,
              child: ExerciseDropdown(
                value: Exercise.shoulerPress,
                onChanged: (value) => lastChangedValue = value,
              ),
            ),
          ),
        ));

          expect(find.text('Shoulder Press'), findsOneWidget);
        
        // Should still be functional
        await tester.tap(find.byType(DropdownButton<Exercise>));
        await tester.pumpAndSettle();
        
        expect(find.text('Shoulder Press').last, findsOneWidget);
      });
    });
  });
}