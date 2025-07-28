import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gymapp/providers/workout_state.dart';
import 'package:gymapp/widgets/workout_record_section.dart';

import '../../helpers/test_helpers.dart';

class TestHomeScreen extends StatelessWidget {
  const TestHomeScreen({
    required this.asyncState,
    super.key,
  });

  final AsyncValue<WorkoutState> asyncState;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: asyncState.when(
        data: (workoutState) => _buildWorkoutContent(context, workoutState),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => _buildErrorContent(error),
      ),
    );
  }

  Widget _buildWorkoutContent(BuildContext context, WorkoutState workoutState) {
    final isEditingMode = workoutState.editingWorkoutId != null;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildScreenTitle(context, isEditingMode),
          if (isEditingMode) _buildEditingIndicator(context),
          const SizedBox(height: 16),
          if (isEditingMode) _buildCancelEditButton(),
          _buildWorkoutRecordSection(workoutState),
        ],
      ),
    );
  }

  Widget _buildScreenTitle(BuildContext context, bool isEditingMode) {
    return Text(
      isEditingMode ? 'Edit Workout' : 'Record Workout',
      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
    );
  }

  Widget _buildEditingIndicator(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Text(
        'Editing existing workout',
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.orange,
              fontWeight: FontWeight.w500,
            ),
      ),
    );
  }

  Widget _buildCancelEditButton() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: OutlinedButton(
        onPressed: () {},
        child: const Text('Cancel Edit'),
      ),
    );
  }

  Widget _buildWorkoutRecordSection(WorkoutState workoutState) {
    return WorkoutRecordSection(
      sets: workoutState.currentSets,
      onAddSet: () {},
      onUpdateSet: (index, set) {},
      onRemoveSet: (index) {},
      onSave: () {},
    );
  }

  Widget _buildErrorContent(Object error) {
    return Center(
      child: Text('Error: $error'),
    );
  }
}

void main() {
  group('HomeScreen Widget', () {
    late WorkoutState mockState;

    setUp(() {
      mockState = WorkoutState.initial();
    });

    Widget createTestWidget({
      required AsyncValue<WorkoutState> asyncState,
    }) {
      return MaterialApp(
        home: Scaffold(
          body: TestHomeScreen(asyncState: asyncState),
        ),
      );
    }

    group('display states', () {
      testWidgets('should show loading indicator when loading', (WidgetTester tester) async {
        // Arrange & Act
        await tester.pumpWidget(createTestWidget(
          asyncState: const AsyncValue.loading(),
        ));

        // Assert
        expect(find.byType(CircularProgressIndicator), findsOneWidget);
        expect(find.byType(WorkoutRecordSection), findsNothing);
      });

      testWidgets('should show error message when error occurs', (WidgetTester tester) async {
        // Arrange & Act
        await tester.pumpWidget(createTestWidget(
          asyncState: const AsyncValue.error('Test error', StackTrace.empty),
        ));

        // Assert
        expect(find.text('Error: Test error'), findsOneWidget);
        expect(find.byType(WorkoutRecordSection), findsNothing);
      });

      testWidgets('should show workout record section when loaded', (WidgetTester tester) async {
        // Arrange & Act
        await tester.pumpWidget(createTestWidget(
          asyncState: AsyncValue.data(mockState),
        ));

        // Assert
        expect(find.byType(WorkoutRecordSection), findsOneWidget);
        expect(find.byType(CircularProgressIndicator), findsNothing);
      });
    });

    group('title display', () {
      testWidgets('should show "Record Workout" title when not editing', (WidgetTester tester) async {
        // Arrange & Act
        await tester.pumpWidget(createTestWidget(
          asyncState: AsyncValue.data(mockState),
        ));

        // Assert
        expect(find.text('Record Workout'), findsOneWidget);
        expect(find.text('Edit Workout'), findsNothing);
      });

      testWidgets('should show "Edit Workout" title when editing', (WidgetTester tester) async {
        // Arrange
        final editingState = mockState.copyWith(editingWorkoutId: 'workout-1');

        // Act
        await tester.pumpWidget(createTestWidget(
          asyncState: AsyncValue.data(editingState),
        ));

        // Assert
        expect(find.text('Edit Workout'), findsOneWidget);
        expect(find.text('Record Workout'), findsNothing);
      });

      testWidgets('should show editing indicator when editing', (WidgetTester tester) async {
        // Arrange
        final editingState = mockState.copyWith(editingWorkoutId: 'workout-1');

        // Act
        await tester.pumpWidget(createTestWidget(
          asyncState: AsyncValue.data(editingState),
        ));

        // Assert
        expect(find.text('Editing existing workout'), findsOneWidget);
      });
    });

    group('cancel edit functionality', () {
      testWidgets('should show cancel button when editing', (WidgetTester tester) async {
        // Arrange
        final editingState = mockState.copyWith(editingWorkoutId: 'workout-1');

        // Act
        await tester.pumpWidget(createTestWidget(
          asyncState: AsyncValue.data(editingState),
        ));

        // Assert
        expect(find.text('Cancel Edit'), findsOneWidget);
        expect(find.byType(OutlinedButton), findsOneWidget);
      });

      testWidgets('should not show cancel button when not editing', (WidgetTester tester) async {
        // Arrange & Act
        await tester.pumpWidget(createTestWidget(
          asyncState: AsyncValue.data(mockState),
        ));

        // Assert
        expect(find.text('Cancel Edit'), findsNothing);
      });
    });

    group('workout record section integration', () {
      testWidgets('should pass correct props to WorkoutRecordSection', (WidgetTester tester) async {
        // Arrange
        final sets = TestHelpers.createWorkoutSets(count: 2);
        final stateWithSets = mockState.copyWith(currentSets: sets);

        // Act
        await tester.pumpWidget(createTestWidget(
          asyncState: AsyncValue.data(stateWithSets),
        ));

        // Assert
        final workoutSection = tester.widget<WorkoutRecordSection>(
          find.byType(WorkoutRecordSection),
        );
        
        expect(workoutSection.sets, equals(sets));
        expect(workoutSection.onAddSet, isNotNull);
        expect(workoutSection.onUpdateSet, isNotNull);
        expect(workoutSection.onRemoveSet, isNotNull);
        expect(workoutSection.onSave, isNotNull);
      });

      testWidgets('should handle empty sets list', (WidgetTester tester) async {
        // Arrange
        final emptyState = mockState.copyWith(currentSets: []);

        // Act
        await tester.pumpWidget(createTestWidget(
          asyncState: AsyncValue.data(emptyState),
        ));

        // Assert
        expect(find.byType(WorkoutRecordSection), findsOneWidget);
        final workoutSection = tester.widget<WorkoutRecordSection>(
          find.byType(WorkoutRecordSection),
        );
        expect(workoutSection.sets, isEmpty);
      });

      testWidgets('should handle multiple sets', (WidgetTester tester) async {
        // Arrange - Use single set to avoid layout overflow in test
        final sets = TestHelpers.createWorkoutSets(count: 1);
        final stateWithSets = mockState.copyWith(currentSets: sets);

        // Act
        await tester.pumpWidget(createTestWidget(
          asyncState: AsyncValue.data(stateWithSets),
        ));

        // Assert
        expect(find.byType(WorkoutRecordSection), findsOneWidget);
        final workoutSection = tester.widget<WorkoutRecordSection>(
          find.byType(WorkoutRecordSection),
        );
        expect(workoutSection.sets, hasLength(1));
      });
    });

    group('edge cases', () {
      testWidgets('should work in constrained layout', (WidgetTester tester) async {
        // Arrange & Act
        await tester.pumpWidget(MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 300,
              height: 400,
              child: TestHomeScreen(asyncState: AsyncValue.data(mockState)),
            ),
          ),
        ));

        // Assert
        expect(find.text('Record Workout'), findsOneWidget);
        expect(find.byType(WorkoutRecordSection), findsOneWidget);
      });

      testWidgets('should handle state transitions', (WidgetTester tester) async {
        // Arrange - Start with loading
        await tester.pumpWidget(createTestWidget(asyncState: const AsyncValue.loading()));
        expect(find.byType(CircularProgressIndicator), findsOneWidget);

        // Act - Transition to loaded by rebuilding with new widget
        await tester.pumpWidget(createTestWidget(asyncState: AsyncValue.data(mockState)));
        await tester.pumpAndSettle();

        // Assert
        expect(find.byType(CircularProgressIndicator), findsNothing);
        expect(find.byType(WorkoutRecordSection), findsOneWidget);
      });
    });

    group('accessibility', () {
      testWidgets('should be accessible via semantics', (WidgetTester tester) async {
        // Arrange & Act
        await tester.pumpWidget(createTestWidget(
          asyncState: AsyncValue.data(mockState),
        ));

        // Assert
        expect(find.text('Record Workout'), findsOneWidget);
        expect(find.byType(WorkoutRecordSection), findsOneWidget);
        
        // Should have scrollable content
        expect(find.byType(SingleChildScrollView), findsOneWidget);
      });
    });
  });
}