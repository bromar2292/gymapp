import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:gymapp/models/workout.dart';
import 'package:gymapp/providers/workout_notifier.dart';
import 'package:gymapp/providers/workout_state.dart';
import 'package:gymapp/widgets/workout_list_section.dart';

class WorkoutsScreen extends ConsumerWidget {
  const WorkoutsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final workoutAsyncValue = ref.watch(workoutNotifierProvider);

    return SafeArea(
      child: workoutAsyncValue.when(
        data: (workoutState) => _buildWorkoutListContent(context, ref, workoutState),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => _buildErrorContent(error),
      ),
    );
  }

  Widget _buildWorkoutListContent(BuildContext context, WidgetRef ref, WorkoutState workoutState) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildScreenTitle(context),
          const SizedBox(height: 16),
          _buildWorkoutListSection(ref, workoutState.workouts),
        ],
      ),
    );
  }

  Widget _buildScreenTitle(BuildContext context) {
    return Text(
      'Workout List',
      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
    );
  }

  Widget _buildWorkoutListSection(WidgetRef ref, List<Workout> workouts) {
    final workoutNotifier = ref.read(workoutNotifierProvider.notifier);

    return WorkoutListSection(
      workouts: workouts,
      onEdit: (workout) => workoutNotifier.loadWorkoutForEdit(workout.id),
      onDelete: workoutNotifier.deleteWorkout,
    );
  }

  Widget _buildErrorContent(Object error) {
    return Center(
      child: Text('Error: $error'),
    );
  }
}
