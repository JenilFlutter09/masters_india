import 'package:flutter/material.dart';

import 'searchable_form_field.dart';

class AppStringDropdownField extends StatelessWidget {
  const AppStringDropdownField({
    required this.label,
    required this.options,
    required this.value,
    required this.onChanged,
    this.validator,
    this.hintText,
    super.key,
  });

  final String label;
  final List<String> options;
  final String? value;
  final void Function(String?) onChanged;
  final String? Function(String?)? validator;
  final String? hintText;

  @override
  Widget build(BuildContext context) {
    final sanitizedValue = options.contains(value) ? value : null;
    return SearchableFormField<String>(
      label: label,
      value: sanitizedValue,
      onChanged: onChanged,
      validator: validator,
      hintText: hintText ?? 'Search and select $label',
      options: options
          .map(
            (option) => SearchableOption<String>(value: option, label: option),
          )
          .toList(),
    );
  }
}
