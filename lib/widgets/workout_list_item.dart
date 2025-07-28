import 'package:flutter/material.dart';

import 'package:gymapp/models/workout.dart';
import 'package:gymapp/utils/extensions.dart';
import 'package:gymapp/utils/theme.dart';

class WorkoutListItem extends StatelessWidget {
  const WorkoutListItem({
    required this.workout,
    required this.onEdit,
    required this.onDelete,
    super.key,
  });

  final Workout workout;

  final VoidCallback onEdit;

  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _buildCardDecoration(),
      child: _buildItemContent(context),
    );
  }

  BoxDecoration _buildCardDecoration() {
    return BoxDecoration(
      color: AppTheme.cardColor,
      borderRadius: BorderRadius.circular(16),
      boxShadow: const [
        BoxShadow(
          color: AppTheme.shadowColor,
          blurRadius: 8,
          offset: Offset(0, 2),
        ),
      ],
    );
  }

  Widget _buildItemContent(BuildContext context) {
    return Row(
      children: [
        _buildWorkoutInformation(context),
        _buildActionButtons(),
      ],
    );
  }

  Widget _buildWorkoutInformation(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildWorkoutDateTitle(context),
          const SizedBox(height: 4),
          _buildWorkoutSummary(context),
          const SizedBox(height: 2),
          _buildWorkoutTimestamp(context),
        ],
      ),
    );
  }

  Widget _buildWorkoutDateTitle(BuildContext context) {
    return Text(
      workout.createdAt.toDisplayDate(),
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
    );
  }

  Widget _buildWorkoutSummary(BuildContext context) {
    return Text(
      workout.summary,
      style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: AppTheme.subtitleColor,
          ),
    );
  }

  Widget _buildWorkoutTimestamp(BuildContext context) {
    return Text(
      workout.createdAt.toFormattedString(),
      style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: AppTheme.subtitleColor,
          ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        _buildEditButton(),
        const SizedBox(width: 8),
        _buildDeleteButton(),
      ],
    );
  }

  Widget _buildEditButton() {
    return OutlinedButton(
      onPressed: onEdit,
      style: OutlinedButton.styleFrom(
        foregroundColor: Colors.blue,
        side: const BorderSide(color: Colors.blue),
      ),
      child: const Text('Edit'),
    );
  }

  Widget _buildDeleteButton() {
    return OutlinedButton(
      onPressed: onDelete,
      style: OutlinedButton.styleFrom(
        foregroundColor: Colors.red,
        side: const BorderSide(color: Colors.red),
      ),
      child: const Text('Delete'),
    );
  }
}
