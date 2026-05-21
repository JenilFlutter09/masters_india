import 'package:flutter/material.dart';

class WorkflowFieldRows extends StatelessWidget {
  const WorkflowFieldRows({required this.rows, super.key});

  final List<List<Widget>> rows;

  static const _breakpoint = 620.0;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= _breakpoint;
        return Column(
          children: rows.map((row) {
            if (row.length <= 1 || !isWide) {
              return Column(children: row);
            }

            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (var index = 0; index < row.length; index++) ...[
                  Expanded(child: row[index]),
                  if (index < row.length - 1) const SizedBox(width: 14),
                ],
              ],
            );
          }).toList(),
        );
      },
    );
  }
}
