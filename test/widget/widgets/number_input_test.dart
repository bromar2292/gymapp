import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gymapp/widgets/number_input.dart';

void _addToValues(List<double> values, double value) => values.add(value);

void main() {
  group('NumberInput Widget', () {
    late double? lastChangedValue;

    setUp(() {
      lastChangedValue = null;
    });

    Widget createTestWidget({
      required double value,
      required void Function(double) onChanged,
      required bool isDecimal,
      required String label,
    }) {
      return MaterialApp(
        home: Scaffold(
          body: NumberInput(
            value: value,
            onChanged: onChanged,
            isDecimal: isDecimal,
            label: label,
          ),
        ),
      );
    }

    group('display and layout', () {
      testWidgets('should display label and current value', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget(
          value: 75.5,
          onChanged: (value) => lastChangedValue = value,
          isDecimal: true,
          label: 'Weight (kg)',
        ));

        expect(find.text('Weight (kg)'), findsOneWidget);
        expect(find.text('75.5'), findsOneWidget);
      });

      testWidgets('should show integer value for non-decimal input', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget(
          value: 12.0,
          onChanged: (value) => lastChangedValue = value,
          isDecimal: false,
          label: 'Reps',
        ));

        expect(find.text('Reps'), findsOneWidget);
        expect(find.text('12'), findsOneWidget);
      });

      testWidgets('should have increment and decrement buttons', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget(
          value: 10.0,
          onChanged: (value) => lastChangedValue = value,
          isDecimal: false,
          label: 'Test',
        ));

        expect(find.byIcon(Icons.arrow_drop_up), findsOneWidget);
        expect(find.byIcon(Icons.arrow_drop_down), findsOneWidget);
      });
    });

    group('text input functionality', () {
      testWidgets('should accept text input and call onChanged', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget(
          value: 50.0,
          onChanged: (value) => lastChangedValue = value,
          isDecimal: true,
          label: 'Weight (kg)',
        ));

        await tester.enterText(find.byType(TextField), '65.5');

        expect(lastChangedValue, 65.5);
      });

      testWidgets('should handle integer input for decimal field', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget(
          value: 50.0,
          onChanged: (value) => lastChangedValue = value,
          isDecimal: true,
          label: 'Weight (kg)',
        ));

        await tester.enterText(find.byType(TextField), '80');

        expect(lastChangedValue, 80.0);
      });

      testWidgets('should handle decimal input for integer field', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget(
          value: 10.0,
          onChanged: (value) => lastChangedValue = value,
          isDecimal: false,
          label: 'Reps',
        ));

        await tester.enterText(find.byType(TextField), '12.5');

        expect(lastChangedValue, 12.0); // Input formatter prevents decimal, only accepts integer part
      });

      testWidgets('should ignore invalid text input', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget(
          value: 50.0,
          onChanged: (value) => lastChangedValue = value,
          isDecimal: true,
          label: 'Weight (kg)',
        ));

        await tester.enterText(find.byType(TextField), 'invalid');

        expect(lastChangedValue, isNull); // Should not call onChanged with invalid input
      });

      testWidgets('should handle empty input', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget(
          value: 50.0,
          onChanged: (value) => lastChangedValue = value,
          isDecimal: true,
          label: 'Weight (kg)',
        ));

        await tester.enterText(find.byType(TextField), '');

        expect(lastChangedValue, isNull); // Should not call onChanged with empty input
      });
    });

    group('increment/decrement buttons', () {
      testWidgets('should increment value when up arrow is tapped', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget(
          value: 50.0,
          onChanged: (value) => lastChangedValue = value,
          isDecimal: true,
          label: 'Weight (kg)',
        ));

        await tester.tap(find.byIcon(Icons.arrow_drop_up));

        expect(lastChangedValue, 51.0);
      });

      testWidgets('should decrement value when down arrow is tapped', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget(
          value: 50.0,
          onChanged: (value) => lastChangedValue = value,
          isDecimal: true,
          label: 'Weight (kg)',
        ));

        await tester.tap(find.byIcon(Icons.arrow_drop_down));

        expect(lastChangedValue, 49.0);
      });

      testWidgets('should not decrement below zero', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget(
          value: 0.0,
          onChanged: (value) => lastChangedValue = value,
          isDecimal: true,
          label: 'Weight (kg)',
        ));

        await tester.tap(find.byIcon(Icons.arrow_drop_down));

        expect(lastChangedValue, isNull); // Should not call onChanged when at zero
      });

      testWidgets('should handle multiple increments', (WidgetTester tester) async {
        final values = <double>[];
        double currentValue = 10.0;
        
        Widget buildWidget() => createTestWidget(
          value: currentValue,
          onChanged: (value) {
            currentValue = value;
            _addToValues(values, value);
          },
          isDecimal: false,
          label: 'Reps',
        );

        await tester.pumpWidget(buildWidget());

        await tester.tap(find.byIcon(Icons.arrow_drop_up));
        await tester.pumpWidget(buildWidget());
        await tester.tap(find.byIcon(Icons.arrow_drop_up));
        await tester.pumpWidget(buildWidget());
        await tester.tap(find.byIcon(Icons.arrow_drop_up));
        await tester.pumpWidget(buildWidget());

        expect(values, [11.0, 12.0, 13.0]);
      });

      testWidgets('should handle mixed increment/decrement', (WidgetTester tester) async {
        final values = <double>[];
        double currentValue = 5.0;
        
        Widget buildWidget() => createTestWidget(
          value: currentValue,
          onChanged: (value) {
            currentValue = value;
            _addToValues(values, value);
          },
          isDecimal: false,
          label: 'Reps',
        );

        await tester.pumpWidget(buildWidget());

        await tester.tap(find.byIcon(Icons.arrow_drop_up));    // 6
        await tester.pumpWidget(buildWidget());
        await tester.tap(find.byIcon(Icons.arrow_drop_up));    // 7
        await tester.pumpWidget(buildWidget());
        await tester.tap(find.byIcon(Icons.arrow_drop_down));  // 6
        await tester.pumpWidget(buildWidget());
        await tester.tap(find.byIcon(Icons.arrow_drop_down));  // 5
        await tester.pumpWidget(buildWidget());

        expect(values, [6.0, 7.0, 6.0, 5.0]);
      });
    });

    group('input formatters', () {
      testWidgets('should apply decimal formatter for decimal input', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget(
          value: 50.0,
          onChanged: (value) => lastChangedValue = value,
          isDecimal: true,
          label: 'Weight (kg)',
        ));

        // Act & Assert
        final textField = tester.widget<TextField>(find.byType(TextField));
        expect(textField.keyboardType, const TextInputType.numberWithOptions(decimal: true));
        
        final formatters = textField.inputFormatters!;
        expect(formatters, hasLength(1));
        expect(formatters[0], isA<FilteringTextInputFormatter>());
      });

      testWidgets('should apply integer formatter for integer input', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget(
          value: 10.0,
          onChanged: (value) => lastChangedValue = value,
          isDecimal: false,
          label: 'Reps',
        ));

        // Act & Assert
        final textField = tester.widget<TextField>(find.byType(TextField));
        expect(textField.keyboardType, const TextInputType.numberWithOptions(decimal: false));
        
        final formatters = textField.inputFormatters!;
        expect(formatters, hasLength(1));
        expect(formatters[0], isA<FilteringTextInputFormatter>());
      });
    });

    group('value updates', () {
      testWidgets('should update display when value prop changes', (WidgetTester tester) async {
        double testValue = 25.0;
        
        await tester.pumpWidget(createTestWidget(
          value: testValue,
          onChanged: (value) => testValue = value,
          isDecimal: true,
          label: 'Weight (kg)',
        ));

        expect(find.text('25.0'), findsOneWidget);

        // Act - Update value and rebuild
        testValue = 35.5;
        await tester.pumpWidget(createTestWidget(
          value: testValue,
          onChanged: (value) => testValue = value,
          isDecimal: true,
          label: 'Weight (kg)',
        ));

        expect(find.text('35.5'), findsOneWidget);
        expect(find.text('25.0'), findsNothing);
      });

      testWidgets('should handle decimal to integer conversion display', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget(
          value: 12.0,
          onChanged: (value) => lastChangedValue = value,
          isDecimal: false,
          label: 'Reps',
        ));

        // Assert - Should display as integer
        expect(find.text('12'), findsOneWidget);
        expect(find.text('12.0'), findsNothing);
      });
    });

    group('edge cases', () {
      testWidgets('should handle very large numbers', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget(
          value: 999.99,
          onChanged: (value) => lastChangedValue = value,
          isDecimal: true,
          label: 'Weight (kg)',
        ));

        expect(find.text('999.99'), findsOneWidget);

        // Test increment
        await tester.tap(find.byIcon(Icons.arrow_drop_up));
        expect(lastChangedValue, 1000.99);
      });

      testWidgets('should handle zero value', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget(
          value: 0.0,
          onChanged: (value) => lastChangedValue = value,
          isDecimal: true,
          label: 'Weight (kg)',
        ));

        expect(find.text('0.0'), findsOneWidget);

        // Test that increment works from zero
        await tester.tap(find.byIcon(Icons.arrow_drop_up));
        expect(lastChangedValue, 1.0);
      });

      testWidgets('should handle decimal values close to zero', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget(
          value: 0.1,
          onChanged: (value) => lastChangedValue = value,
          isDecimal: true,
          label: 'Weight (kg)',
        ));

        // Act - Decrement below 1
        await tester.tap(find.byIcon(Icons.arrow_drop_down));

        // Assert - Should not go negative
        expect(lastChangedValue, isNull);
      });

      testWidgets('should work in constrained layout', (WidgetTester tester) async {
        await tester.pumpWidget(MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 150,
              height: 80,
              child: NumberInput(
                value: 42.5,
                onChanged: (value) => lastChangedValue = value,
                isDecimal: true,
                label: 'Weight',
              ),
            ),
          ),
        ));

        expect(find.text('Weight'), findsOneWidget);
        expect(find.text('42.5'), findsOneWidget);
        
        // Should still be functional
        await tester.tap(find.byIcon(Icons.arrow_drop_up));
        expect(lastChangedValue, 43.5);
      });

      testWidgets('should handle rapid button presses', (WidgetTester tester) async {
        final values = <double>[];
        double currentValue = 10.0;
        
        Widget buildWidget() => createTestWidget(
          value: currentValue,
          onChanged: (value) {
            currentValue = value;
            _addToValues(values, value);
          },
          isDecimal: false,
          label: 'Reps',
        );

        await tester.pumpWidget(buildWidget());

        // Act - Rapid presses with proper state updates
        for (int i = 0; i < 5; i++) {
          await tester.tap(find.byIcon(Icons.arrow_drop_up));
          await tester.pumpWidget(buildWidget()); // Update widget with new value
        }

        expect(values, [11.0, 12.0, 13.0, 14.0, 15.0]);
      });
    });

    group('accessibility', () {
      testWidgets('should be accessible via semantics', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget(
          value: 50.0,
          onChanged: (value) => lastChangedValue = value,
          isDecimal: true,
          label: 'Weight (kg)',
        ));

        expect(find.byType(TextField), findsOneWidget);
        expect(find.byType(InkWell), findsNWidgets(2)); // Two buttons

        // Buttons should be tappable
        await tester.tap(find.byIcon(Icons.arrow_drop_up));
        expect(lastChangedValue, 51.0);
      });
    });
  });
}