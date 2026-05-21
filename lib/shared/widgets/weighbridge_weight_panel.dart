import 'package:flutter/material.dart';

import '../../core/models/scale_reading.dart';
import 'app_text_field.dart';
import 'section_card.dart';

class WeighbridgeWeightPanel extends StatefulWidget {
  const WeighbridgeWeightPanel({
    required this.scaleStatus,
    required this.isScaleConnected,
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
  final bool isScaleConnected;
  final String printerStatus;
  final ScaleReading? liveReading;
  final TextEditingController grossWeightController;
  final TextEditingController tareWeightController;
  final VoidCallback onCaptureGross;
  final VoidCallback onCaptureTare;
  final String? Function(String?) grossValidator;
  final String? Function(String?) tareValidator;

  @override
  State<WeighbridgeWeightPanel> createState() => _WeighbridgeWeightPanelState();
}

class _WeighbridgeWeightPanelState extends State<WeighbridgeWeightPanel> {
  @override
  void didUpdateWidget(covariant WeighbridgeWeightPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    _syncGrossFromLiveReading();
  }

  void _syncGrossFromLiveReading() {
    if (!widget.isScaleConnected || widget.liveReading == null) {
      return;
    }

    final nextValue = widget.liveReading!.weight.toStringAsFixed(2);
    if (widget.grossWeightController.text.trim() == nextValue) {
      return;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      widget.grossWeightController.text = nextValue;
    });
  }

  double _parseWeight(TextEditingController controller) =>
      double.tryParse(controller.text.trim()) ?? 0;

  @override
  Widget build(BuildContext context) {
    _syncGrossFromLiveReading();
    final grossListenable = Listenable.merge([
      widget.grossWeightController,
      widget.tareWeightController,
    ]);

    return SectionCard(
      title: widget.title,
      //subtitle: widget.subtitle,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              Chip(label: Text('Scale: ${widget.scaleStatus}')),
              Chip(label: Text('Printer: ${widget.printerStatus}')),
              // Chip(
              //   label: Text(
              //     widget.isScaleConnected
              //         ? 'Live gross mode'
              //         : 'Manual gross mode',
              //   ),
              // ),
            ],
          ),
          const SizedBox(height: 18),
          ListenableBuilder(
            listenable: grossListenable,
            builder: (context, _) {
              final grossWeight = widget.isScaleConnected
                  ? (widget.liveReading?.weight ??
                        _parseWeight(widget.grossWeightController))
                  : _parseWeight(widget.grossWeightController);
              final tareWeight = _parseWeight(widget.tareWeightController);
              final netWeight = grossWeight - tareWeight;

              return Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _WeightDisplayCard(
                          title: 'Gross Weight',
                          value: grossWeight,
                          emphasize: true,
                          accent: const Color(0xFF1F5FBF),
                          child: widget.isScaleConnected
                              ? AppTextField(
                            label: 'Live Gross Weight',
                            controller: widget.grossWeightController,
                            keyboardType:
                            TextInputType.none,
                            readOnly: true,
                            validator: widget.grossValidator,
                          )
                              : AppTextField(
                                  label: 'Manual Gross Weight',
                                  controller: widget.grossWeightController,
                                  keyboardType:
                                      const TextInputType.numberWithOptions(
                                        decimal: true,
                                      ),
                                  validator: widget.grossValidator,
                                ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _WeightDisplayCard(
                          title: 'Tare Weight',
                          value: tareWeight,
                          accent: const Color(0xFFB96A12),
                          child: AppTextField(
                            label: 'Tare Weight',
                            controller: widget.tareWeightController,
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            validator: widget.tareValidator,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _WeightDisplayCard(
                    title: 'Net Weight',
                    value: netWeight,
                    emphasize: true,
                    accent: const Color(0xFF0E8D63),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _WeightDisplayCard extends StatelessWidget {
  const _WeightDisplayCard({
    required this.title,
    required this.value,
    required this.accent,
    this.emphasize = false,
    this.child,
  });

  final String title;
  final double value;
  final Color accent;
  final bool emphasize;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
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
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title.toUpperCase(),
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: accent,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          value.toStringAsFixed(3),
                          style:
                              (emphasize
                                      ? theme.textTheme.displaySmall
                                      : theme.textTheme.headlineMedium)
                                  ?.copyWith(
                                    color: const Color(0xFF172033),
                                    fontWeight: FontWeight.w900,
                                    height: 1,
                                  ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'KG',
                          style: theme.textTheme.labelLarge?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (child != null) ...[const SizedBox(height: 14), child!],
        ],
      ),
    );
  }
}
