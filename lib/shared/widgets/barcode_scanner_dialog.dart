import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

Future<String?> showBarcodeScannerDialog(BuildContext context) async {
  String? scannedCode;

  await Get.dialog<void>(
    Center(
      child: Material(
        color: Colors.transparent,
        child: Container(
          width: MediaQuery.of(context).size.width * 0.9,
          height: 320,
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(20),
            boxShadow: const [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 20,
                offset: Offset(0, 8),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Stack(
              children: [
                MobileScanner(
                  onDetect: (capture) {
                    final barcodes = capture.barcodes;
                    if (barcodes.isEmpty) {
                      return;
                    }
                    final code = barcodes.first.rawValue;
                    if (code == null || scannedCode != null) {
                      return;
                    }
                    scannedCode = code;
                    Get.back<void>();
                  },
                ),
                const _BarcodeOverlayDialog(),
                Positioned(
                  bottom: 10,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: ElevatedButton.icon(
                      onPressed: () => Get.back<void>(),
                      icon: const Icon(Icons.close),
                      label: const Text('Cancel'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 10,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
    barrierDismissible: false,
    useSafeArea: false,
  );

  return scannedCode;
}

class _BarcodeOverlayDialog extends StatefulWidget {
  const _BarcodeOverlayDialog();

  @override
  State<_BarcodeOverlayDialog> createState() => _BarcodeOverlayDialogState();
}

class _BarcodeOverlayDialogState extends State<_BarcodeOverlayDialog>
    with SingleTickerProviderStateMixin {
  late final AnimationController _laserController;

  @override
  void initState() {
    super.initState();
    _laserController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _laserController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final containerSize = 320.0;
    final width = MediaQuery.of(context).size.width * 0.9;
    final cutOutWidth = width * 0.9;
    const cutOutHeight = 180.0;
    final centerY = containerSize / 2 - 20;

    final cutOutRect = Rect.fromCenter(
      center: Offset(width / 2, centerY),
      width: cutOutWidth,
      height: cutOutHeight,
    );

    return Stack(
      children: [
        Container(
          width: width,
          height: containerSize,
          decoration: ShapeDecoration(
            shape: _BarcodeScannerOverlay(
              borderColor: Theme.of(context).colorScheme.primary,
              cutOutWidth: cutOutWidth,
              cutOutHeight: cutOutHeight,
            ),
          ),
        ),
        AnimatedBuilder(
          animation: _laserController,
          builder: (_, __) {
            final yPos =
                cutOutRect.top + (cutOutRect.height * _laserController.value);
            return Positioned(
              left: cutOutRect.left,
              width: cutOutRect.width,
              top: yPos + 20,
              child: Container(
                height: 2,
                color: Colors.white.withValues(alpha: 0.8),
              ),
            );
          },
        ),
      ],
    );
  }
}

class _BarcodeScannerOverlay extends ShapeBorder {
  const _BarcodeScannerOverlay({
    required this.borderColor,
    required this.cutOutWidth,
    required this.cutOutHeight,
  });

  final Color borderColor;
  final double cutOutWidth;
  final double cutOutHeight;

  @override
  EdgeInsetsGeometry get dimensions => EdgeInsets.zero;

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) =>
      Path()..addRect(rect);

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) =>
      Path()..addRect(rect);

  @override
  void paint(
    Canvas canvas,
    Rect rect, {
    TextDirection? textDirection,
    BoxShape shape = BoxShape.rectangle,
    BorderRadius borderRadius = BorderRadius.zero,
  }) {
    final paint = Paint()
      ..color = Colors.black54
      ..style = PaintingStyle.fill;

    final cutOutRect = Rect.fromCenter(
      center: rect.center,
      width: cutOutWidth,
      height: cutOutHeight,
    );

    canvas.drawPath(
      Path.combine(
        PathOperation.difference,
        Path()..addRect(rect),
        Path()..addRRect(
          RRect.fromRectXY(cutOutRect, 8, 8),
        ),
      ),
      paint,
    );

    final borderPaint = Paint()
      ..color = borderColor
      ..strokeWidth = 5
      ..style = PaintingStyle.stroke;

    final path = Path()
      ..moveTo(cutOutRect.left, cutOutRect.top + 30)
      ..lineTo(cutOutRect.left, cutOutRect.top)
      ..lineTo(cutOutRect.left + 30, cutOutRect.top)
      ..moveTo(cutOutRect.right - 30, cutOutRect.top)
      ..lineTo(cutOutRect.right, cutOutRect.top)
      ..lineTo(cutOutRect.right, cutOutRect.top + 30)
      ..moveTo(cutOutRect.right, cutOutRect.bottom - 30)
      ..lineTo(cutOutRect.right, cutOutRect.bottom)
      ..lineTo(cutOutRect.right - 30, cutOutRect.bottom)
      ..moveTo(cutOutRect.left + 30, cutOutRect.bottom)
      ..lineTo(cutOutRect.left, cutOutRect.bottom)
      ..lineTo(cutOutRect.left, cutOutRect.bottom - 30);

    canvas.drawPath(path, borderPaint);
  }

  @override
  ShapeBorder scale(double t) => this;
}
