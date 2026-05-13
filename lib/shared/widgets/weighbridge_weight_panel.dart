import 'package:flutter/material.dart';

import '../../core/models/scale_reading.dart';
import 'app_text_field.dart';
import 'section_card.dart';

class WeighbridgeWeightPanel extends StatelessWidget {
  const WeighbridgeWeightPanel({
    required this.scaleStatus,
    required this.printerStatus,
    required this.liveReading,
    required this.grossWeightController,
    required this.tareWeightController,
    required this.onCaptureGross,
    required this.onCaptureTare,
    required this.grossValidator,
    required this.tareValidator,
    this.title = 'Weight Station',
    this.subtitle =
        'Review the live scale signal and push each reading into gross or tare before saving.',
    super.key,
  });

  final String title;
  final String subtitle;
  final String scaleStatus;
  final String printerStatus;
  final ScaleReading? liveReading;
  final TextEditingController grossWeightController;
  final TextEditingController tareWeightController;
  final VoidCallback onCaptureGross;
  final VoidCallback onCaptureTare;
  final String? Function(String?) grossValidator;
  final String? Function(String?) tareValidator;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SectionCard(
      title: title,
      subtitle: subtitle,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              Chip(label: Text('Scale: $scaleStatus')),
              Chip(label: Text('Printer: $printerStatus')),
            ],
          ),
          const SizedBox(height: 18),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
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
                  liveReading == null
                      ? '--.--'
                      : liveReading!.weight.toStringAsFixed(2),
                  style: theme.textTheme.displaySmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    height: 1,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  liveReading == null
                      ? 'Waiting for device reading'
                      : '${liveReading!.unit} ${liveReading!.isStable ? '• stable signal' : '• reading in motion'}',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onCaptureGross,
                  icon: const Icon(Icons.south_west_rounded),
                  label: const Text('Send to Gross'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onCaptureTare,
                  icon: const Icon(Icons.north_east_rounded),
                  label: const Text('Send to Tare'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          AppTextField(
            label: 'Gross Weight',
            controller: grossWeightController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            validator: grossValidator,
          ),
          AppTextField(
            label: 'Tare Weight',
            controller: tareWeightController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            validator: tareValidator,
          ),
        ],
      ),
    );
  }
}
