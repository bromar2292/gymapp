import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:gymapp/providers/workout_notifier.dart';
import 'package:gymapp/providers/workout_state.dart';
import 'package:gymapp/widgets/workout_record_section.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final workoutAsyncValue = ref.watch(workoutNotifierProvider);

    return SafeArea(
      child: workoutAsyncValue.when(
        data: (workoutState) => _buildWorkoutContent(context, ref, workoutState),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => _buildErrorContent(error),
      ),
    );
  }

  Widget _buildWorkoutContent(BuildContext context, WidgetRef ref, WorkoutState workoutState) {
    final isEditingMode = workoutState.editingWorkoutId != null;
    final workoutNotifier = ref.read(workoutNotifierProvider.notifier);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildScreenTitle(context, isEditingMode),
          if (isEditingMode) _buildEditingIndicator(context),
          const SizedBox(height: 16),
          if (isEditingMode) _buildCancelEditButton(workoutNotifier),
          _buildWorkoutRecordSection(workoutState, workoutNotifier),
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

  Widget _buildCancelEditButton(WorkoutNotifier workoutNotifier) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: OutlinedButton(
        onPressed: () => workoutNotifier.clearCurrentWorkout(),
        child: const Text('Cancel Edit'),
      ),
    );
  }

  Widget _buildWorkoutRecordSection(WorkoutState workoutState, WorkoutNotifier workoutNotifier) {
    return WorkoutRecordSection(
      sets: workoutState.currentSets,
      onAddSet: () => workoutNotifier.addSet(),
      onUpdateSet: workoutNotifier.updateSet,
      onRemoveSet: workoutNotifier.removeSet,
      onSave: () => workoutNotifier.saveCurrentWorkout(),
    );
  }

  Widget _buildErrorContent(Object error) {
    return Center(
      child: Text('Error: $error'),
    );
  }
}
