import 'package:flutter/material.dart';

import 'package:gymapp/models/exercise.dart';
import 'package:gymapp/models/workout_set.dart';
import 'package:gymapp/utils/theme.dart';
import 'package:gymapp/widgets/exercise_dropdown.dart';
import 'package:gymapp/widgets/number_input.dart';

class WorkoutSetCard extends StatelessWidget {
  const WorkoutSetCard({
    required this.currentSet,
    required this.displaySetNumber,
    required this.onSetUpdate,
    required this.onSetRemove,
    super.key,
  });

  final WorkoutSet currentSet;

  final int displaySetNumber;

  final void Function(WorkoutSet) onSetUpdate;

  final VoidCallback onSetRemove;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: _buildCardDecoration(),
      child: _buildCardContent(context),
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

  Widget _buildCardContent(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildSetHeaderRow(context),
        const SizedBox(height: 8),
        _buildExerciseDropdown(),
        const SizedBox(height: 8),
        _buildWeightAndRepsRow(),
      ],
    );
  }

  Widget _buildSetHeaderRow(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildSetNumberTitle(context),
        _buildRemoveSetButton(),
      ],
    );
  }

  Widget _buildSetNumberTitle(BuildContext context) {
    return Text(
      'Set $displaySetNumber',
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
    );
  }

  Widget _buildRemoveSetButton() {
    return OutlinedButton(
      onPressed: onSetRemove,
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      child: const Text('Remove set', style: TextStyle(fontSize: 12)),
    );
  }

  Widget _buildExerciseDropdown() {
    return ExerciseDropdown(
      value: currentSet.exercise,
      onChanged: _handleExerciseChange,
    );
  }

  void _handleExerciseChange(Exercise? selectedExercise) {
    if (selectedExercise != null) {
      onSetUpdate(currentSet.copyWith(exercise: selectedExercise));
    }
  }

  Widget _buildWeightAndRepsRow() {
    return Row(
      children: [
        _buildWeightInput(),
        const SizedBox(width: 16),
        _buildRepsInput(),
      ],
    );
  }

  Widget _buildWeightInput() {
    return Expanded(
      child: NumberInput(
        value: currentSet.weightKg,
        onChanged: _handleWeightChange,
        isDecimal: true,
        label: 'Weight (kg)',
      ),
    );
  }

  void _handleWeightChange(double newWeight) {
    onSetUpdate(currentSet.copyWith(weightKg: newWeight));
  }

  Widget _buildRepsInput() {
    return Expanded(
      child: NumberInput(
        value: currentSet.reps.toDouble(),
        onChanged: _handleRepsChange,
        isDecimal: false,
        label: 'Reps',
      ),
    );
  }

  void _handleRepsChange(double newReps) {
    onSetUpdate(currentSet.copyWith(reps: newReps.toInt()));
  }
}
