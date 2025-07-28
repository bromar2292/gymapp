import 'package:flutter/material.dart';
import 'package:gymapp/models/exercise.dart';
import 'package:gymapp/utils/theme.dart';

class ExerciseDropdown extends StatelessWidget {
  const ExerciseDropdown({
    required this.value,
    required this.onChanged,
    super.key,
  });

  final Exercise value;

  final void Function(Exercise?) onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: _buildDropdownDecoration(),
      child: _buildStyledDropdownButton(),
    );
  }

  BoxDecoration _buildDropdownDecoration() {
    return BoxDecoration(
      color: AppTheme.inputBackgroundColor,
      borderRadius: BorderRadius.circular(8),
    );
  }

  Widget _buildStyledDropdownButton() {
    return DropdownButtonHideUnderline(
      child: DropdownButton<Exercise>(
        value: value,
        isExpanded: true,
        onChanged: onChanged,
        items: _buildExerciseDropdownItems(),
      ),
    );
  }

  List<DropdownMenuItem<Exercise>> _buildExerciseDropdownItems() {
    return Exercise.values.map((currentExercise) {
      return DropdownMenuItem(
        value: currentExercise,
        child: Text(currentExercise.displayName),
      );
    }).toList();
  }
}
