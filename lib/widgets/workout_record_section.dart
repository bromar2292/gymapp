import 'package:flutter/material.dart';

import 'package:gymapp/models/workout_set.dart';
import 'package:gymapp/widgets/workout_set_card.dart';

class WorkoutRecordSection extends StatelessWidget {
  const WorkoutRecordSection({
    required this.sets,
    required this.onAddSet,
    required this.onUpdateSet,
    required this.onRemoveSet,
    required this.onSave,
    super.key,
  });

  final List<WorkoutSet> sets;

  final VoidCallback onAddSet;

  final void Function(int setIndex, WorkoutSet updatedSet) onUpdateSet;

  final void Function(int setIndex) onRemoveSet;

  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ..._buildWorkoutSetCards(),
        _buildAddSetButton(),
        if (sets.isNotEmpty) ..._buildSaveWorkoutSection(),
      ],
    );
  }

  List<Widget> _buildWorkoutSetCards() {
    return sets.asMap().entries.map((setEntry) {
      final setIndex = setEntry.key;
      final currentSet = setEntry.value;

      return Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: WorkoutSetCard(
          currentSet: currentSet,
          displaySetNumber: setIndex + 1,
          onSetUpdate: (modifiedSet) => onUpdateSet(setIndex, modifiedSet),
          onSetRemove: () => onRemoveSet(setIndex),
        ),
      );
    }).toList();
  }

  Widget _buildAddSetButton() {
    return ElevatedButton(
      onPressed: onAddSet,
      child: const Text('Add Set'),
    );
  }

  List<Widget> _buildSaveWorkoutSection() {
    return [
      const SizedBox(height: 16),
      _buildSaveWorkoutButton(),
    ];
  }

  Widget _buildSaveWorkoutButton() {
    return ElevatedButton(
      onPressed: onSave,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.green,
      ),
      child: const Text('Save Workout'),
    );
  }
}
