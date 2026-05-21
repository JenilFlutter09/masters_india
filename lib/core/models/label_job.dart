class LabelJob {
  const LabelJob({
    required this.title,
    required this.lines,
    this.barcodeValue,
    this.copies = 1,
  });

  final String title;
  final List<String> lines;
  final String? barcodeValue;
  final int copies;
}
