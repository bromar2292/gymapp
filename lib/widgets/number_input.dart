import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gymapp/utils/theme.dart';

class NumberInput extends StatelessWidget {
  const NumberInput({
    required this.value,
    required this.onChanged,
    required this.isDecimal,
    required this.label,
    super.key,
  });

  final double value;

  final void Function(double) onChanged;

  final bool isDecimal;

  final String label;

  @override
  Widget build(BuildContext context) {
    final textController = TextEditingController(
      text: _formatDisplayValue(),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildInputLabel(context),
        const SizedBox(height: 4),
        _buildInputContainer(textController),
      ],
    );
  }

  String _formatDisplayValue() {
    return isDecimal ? value.toString() : value.toInt().toString();
  }

  Widget _buildInputLabel(BuildContext context) {
    return Text(
      label,
      style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: AppTheme.subtitleColor,
          ),
    );
  }

  Widget _buildInputContainer(TextEditingController textController) {
    return Container(
      decoration: _buildContainerDecoration(),
      child: Row(
        children: [
          _buildExpandedTextField(textController),
          _buildIncrementDecrementButtons(),
          const SizedBox(width: 8),
        ],
      ),
    );
  }

  BoxDecoration _buildContainerDecoration() {
    return BoxDecoration(
      color: AppTheme.inputBackgroundColor,
      borderRadius: BorderRadius.circular(8),
    );
  }

  Widget _buildExpandedTextField(TextEditingController textController) {
    return Expanded(
      child: TextField(
        controller: textController,
        keyboardType: TextInputType.numberWithOptions(decimal: isDecimal),
        inputFormatters: [_createInputFormatter()],
        decoration: const InputDecoration(
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 16),
        ),
        onChanged: _handleTextFieldChange,
      ),
    );
  }

  TextInputFormatter _createInputFormatter() {
    final pattern = isDecimal ? RegExp(r'^\d*\.?\d*') : RegExp(r'^\d*');
    return FilteringTextInputFormatter.allow(pattern);
  }

  void _handleTextFieldChange(String inputText) {
    if (inputText.isEmpty) {
      return;
    }
    
    final parsedValue = double.tryParse(inputText);
    if (parsedValue != null && parsedValue >= 0) {
      onChanged(parsedValue);
    }
  }

  Widget _buildIncrementDecrementButtons() {
    return Column(
      children: [
        _buildIncrementButton(),
        _buildDecrementButton(),
      ],
    );
  }

  Widget _buildIncrementButton() {
    return InkWell(
      onTap: () => onChanged(value + 1),
      child: Container(
        padding: const EdgeInsets.all(4),
        child: const Icon(Icons.arrow_drop_up, size: 20),
      ),
    );
  }

  Widget _buildDecrementButton() {
    return InkWell(
      onTap: () {
        final newValue = value - 1;
        if (newValue >= 0) {
          onChanged(newValue);
        }
      },
      child: Container(
        padding: const EdgeInsets.all(4),
        child: const Icon(Icons.arrow_drop_down, size: 20),
      ),
    );
  }
}
