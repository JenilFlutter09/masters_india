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
    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: controller.weightController,
      builder: (context, _, __) {
        return Obx(() {
          final reading = controller.liveReading.value;
          final theme = Theme.of(context);
          final displayWeight = controller.useManualWeight.value
              ? (double.tryParse(controller.weightController.text.trim()) ?? 0)
              : (reading?.weight ??
                    double.tryParse(controller.weightController.text.trim()) ??
                    0);
          final displayUnit = reading?.unit ?? 'kg';

          return SectionCard(
            title: 'Weight Station',
            subtitle:
                'Use the live scale signal when available, or switch to manual mode for direct single-weight entry.',
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
                            : 'Live device mode',
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
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: theme.dividerColor),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x0D163A66),
                        blurRadius: 16,
                        offset: Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        controller.useManualWeight.value
                            ? 'CAPTURED WEIGHT'
                            : 'LIVE WEIGHT',
                        style: theme.textTheme.labelLarge?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        displayWeight.toStringAsFixed(2),
                        style: theme.textTheme.displaySmall?.copyWith(
                          color: const Color(0xFF172033),
                          fontWeight: FontWeight.w900,
                          height: 1,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        displayUnit.toUpperCase(),
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.8,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        controller.useManualWeight.value
                            ? 'Scale is unavailable or manual mode is enabled. Enter the weight directly below.'
                            : reading == null
                            ? 'Waiting for live scale signal. Pull the latest reading when the device starts streaming.'
                            : reading.isStable
                            ? 'Live scale signal is stable and ready to use.'
                            : 'Live scale signal is in motion and still updating.',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                          height: 1.35,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF6F8FC),
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(color: theme.dividerColor),
                  ),
                  child: Column(
                    children: [
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text('Manual weight entry'),
                        subtitle: Text(
                          controller.useManualWeight.value
                              ? 'Turn this off to mirror the connected scale reading.'
                              : 'Turn this on if you need to type the final weight manually.',
                        ),
                        value: controller.useManualWeight.value,
                        onChanged: controller.toggleManualWeight,
                      ),
                      if (!controller.useManualWeight.value) ...[
                        const SizedBox(height: 4),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: OutlinedButton.icon(
                            onPressed: controller.captureLiveWeight,
                            icon: const Icon(Icons.sensors_outlined),
                            label: const Text('Pull live reading'),
                          ),
                        ),
                      ],
                      const SizedBox(height: 12),
                      AppTextField(
                        label: controller.useManualWeight.value
                            ? 'Manual Weight (kg)'
                            : 'Captured Weight (kg)',
                        controller: controller.weightController,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        validator: controller.weightValidator,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        });
      },
    );
  }
}
