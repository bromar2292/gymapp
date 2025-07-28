import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:gymapp/models/workout.dart';
import 'package:gymapp/routing/app_router.dart';
import 'package:gymapp/widgets/workout_list_item.dart';

class WorkoutListSection extends StatelessWidget {
  const WorkoutListSection({
    required this.workouts,
    required this.onEdit,
    required this.onDelete,
    super.key,
  });

  final List<Workout> workouts;

  final void Function(Workout) onEdit;

  final void Function(String) onDelete;

  @override
  Widget build(BuildContext context) {
    return workouts.isEmpty
        ? _buildEmptyStateMessage(context)
        : _buildWorkoutList(context);
  }

  Widget _buildEmptyStateMessage(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Text(
          'No workouts yet. Start by recording your first workout!',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Colors.grey,
              ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildWorkoutList(BuildContext context) {
    return Column(
      children: workouts.map((currentWorkout) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: _buildWorkoutListItem(context, currentWorkout),
        );
      }).toList(),
    );
  }

  Widget _buildWorkoutListItem(BuildContext context, Workout currentWorkout) {
    return WorkoutListItem(
      workout: currentWorkout,
      onEdit: () => _handleEditWorkout(context, currentWorkout),
      onDelete: () => onDelete(currentWorkout.id),
    );
  }

  void _handleEditWorkout(BuildContext context, Workout workoutToEdit) {
    onEdit(workoutToEdit);
    context.go(AppRouter.home);
  }
}
