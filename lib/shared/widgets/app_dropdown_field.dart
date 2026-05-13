import 'package:flutter/material.dart';

import '../../core/models/master_option.dart';

class AppDropdownField extends StatelessWidget {
  const AppDropdownField({
    required this.label,
    required this.options,
    required this.value,
    required this.onChanged,
    this.validator,
    super.key,
  });

  final String label;
  final List<MasterOption> options;
  final int? value;
  final void Function(int?) onChanged;
  final String? Function(int?)? validator;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: DropdownButtonFormField<int>(
        key: ValueKey('$label-$value-${options.length}'),
        initialValue: value,
        decoration: InputDecoration(labelText: label),
        items: options
            .map(
              (option) => DropdownMenuItem<int>(
                value: option.id,
                child: Text(option.name),
              ),
            )
            .toList(),
        onChanged: onChanged,
        validator: validator,
      ),
    );
  }
}
