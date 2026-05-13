import 'package:flutter/material.dart';

class StatusBanner extends StatelessWidget {
  const StatusBanner({required this.message, required this.isError, super.key});

  final String message;
  final bool isError;

  @override
  Widget build(BuildContext context) {
    final color = isError ? Colors.red.shade50 : Colors.green.shade50;
    final border = isError ? Colors.red.shade200 : Colors.green.shade200;
    final text = isError ? Colors.red.shade900 : Colors.green.shade900;
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: border),
      ),
      child: Text(
        message,
        style: TextStyle(color: text, fontWeight: FontWeight.w600),
      ),
    );
  }
}
