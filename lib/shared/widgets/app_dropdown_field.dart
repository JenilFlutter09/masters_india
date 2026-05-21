import 'package:flutter/material.dart';

import '../../core/models/master_option.dart';
import 'searchable_form_field.dart';

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
    return SearchableFormField<int>(
      label: label,
      value: value,
      onChanged: onChanged,
      validator: validator,
     // hintText: 'Search and select $label',
      options: options
          .map(
            (option) =>
                SearchableOption<int>(value: option.id, label: option.name),
          )
          .toList(),
    );
  }
}
