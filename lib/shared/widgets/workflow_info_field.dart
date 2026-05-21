import 'package:flutter/material.dart';

class WorkflowInfoField extends StatelessWidget {
  const WorkflowInfoField({
    required this.label,
    required this.value,
    this.muted = false,
    super.key,
  });

  final String label;
  final String value;
  final bool muted;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: InputDecorator(
        decoration: InputDecoration(labelText: label),
        child: Text(
          value,
          style: theme.textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.w600,
            color: muted ? theme.colorScheme.onSurfaceVariant : null,
          ),
        ),
      ),
    );
  }
}
