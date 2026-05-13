class ScaleReading {
  const ScaleReading({
    required this.raw,
    required this.weight,
    required this.unit,
    required this.isStable,
    required this.capturedAt,
  });

  final String raw;
  final double weight;
  final String unit;
  final bool isStable;
  final DateTime capturedAt;
}
