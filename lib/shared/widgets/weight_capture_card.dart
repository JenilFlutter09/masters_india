import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../features/workflow/presentation/workflow_form_controller.dart';
import 'app_text_field.dart';
import 'section_card.dart';

class WeightCaptureCard extends StatelessWidget {
  const WeightCaptureCard({required this.controller, super.key});

  final WorkflowFormController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final reading = controller.liveReading.value;
      final theme = Theme.of(context);
      return SectionCard(
        title: 'Weight Station',
        subtitle:
            'Use the live scale signal when available, or switch to manual mode for direct entry.',
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                Chip(label: Text('Scale: ${controller.scaleStatus}')),
                Chip(label: Text('Printer: ${controller.printerStatus}')),
                Chip(
                  label: Text(
                    controller.useManualWeight.value
                        ? 'Manual mode'
                        : 'Device mode',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            Container(
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 14),
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF1F1715), Color(0xFF3C251B)],
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'LIVE SCALE',
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: Colors.white70,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    reading == null
                        ? '--.--'
                        : reading.weight.toStringAsFixed(2),
                    style: theme.textTheme.displaySmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      height: 1,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    reading == null
                        ? 'Waiting for device reading'
                        : '${reading.unit}${reading.isStable ? ' • stable signal' : ' • reading in motion'}',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Manual weight entry'),
              subtitle: const Text(
                'Turn off when you want to capture the latest live reading.',
              ),
              value: controller.useManualWeight.value,
              onChanged: controller.toggleManualWeight,
            ),
            if (!controller.useManualWeight.value)
              Align(
                alignment: Alignment.centerLeft,
                child: OutlinedButton.icon(
                  onPressed: controller.captureLiveWeight,
                  icon: const Icon(Icons.sensors_outlined),
                  label: const Text('Pull live reading'),
                ),
              ),
            const SizedBox(height: 12),
            AppTextField(
              label: 'Weight (kg)',
              controller: controller.weightController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              validator: controller.weightValidator,
            ),
          ],
        ),
      );
    });
  }
}
