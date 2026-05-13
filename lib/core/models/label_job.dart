class LabelJob {
  const LabelJob({required this.title, required this.lines, this.barcodeValue});

  final String title;
  final List<String> lines;
  final String? barcodeValue;
}
