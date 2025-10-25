import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../l10n/app_localizations.dart';

class QrScannerScreen extends StatefulWidget {
  const QrScannerScreen({super.key});

  @override
  State<QrScannerScreen> createState() => _QrScannerScreenState();
}

class _QrScannerScreenState extends State<QrScannerScreen>
    with SingleTickerProviderStateMixin {
  MobileScannerController cameraController = MobileScannerController();
  bool _isScanning = true;
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    cameraController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(l10n.scanQrCode),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: () => cameraController.toggleTorch(),
            icon: const Icon(Icons.flash_on, size: 28),
          ),
          IconButton(
            onPressed: () => cameraController.switchCamera(),
            icon: const Icon(Icons.camera_front, size: 28),
          ),
        ],
      ),
      body: Stack(
        children: [
          MobileScanner(controller: cameraController, onDetect: _onDetect),
          _buildGradientOverlay(),
          if (_isScanning) _buildAdvancedScannerOverlay(),
          if (_isScanning) _buildScanningLine(),
          if (_isScanning) _buildAnimatedCorners(),
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: _buildInstructions(),
          ),
        ],
      ),
    );
  }

  Widget _buildGradientOverlay() {
    return Stack(
      children: [
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: Container(
            height: 150,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.7),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            height: 200,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.black.withValues(alpha: 0.8),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAdvancedScannerOverlay() {
    return CustomPaint(painter: AdvancedScannerPainter());
  }

  double _getCutOutSize() {
    final screenWidth = MediaQuery.of(context).size.width;
    return (screenWidth * 0.7).clamp(200.0, 350.0);
  }

  double _getCornerOffset() {
    return _getCutOutSize() / 2;
  }

  Widget _buildScanningLine() {
    return Positioned(
      top: MediaQuery.of(context).size.height * 0.42 - _getCornerOffset(),
      left: MediaQuery.of(context).size.width * 0.5 - _getCornerOffset(),
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          return Opacity(
            // 1. Opaklığı %30'dan %70'e çıkar
            opacity: 0.4,
            child: Container(
              width: _getCutOutSize(),
              height: 200,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.transparent,
                    Theme.of(context).colorScheme.primary,
                    Colors.transparent,
                  ],
                  stops: [0.0, 0.5 + (_animation.value - 0.5) * 0.5, 1.0],
                ),
              ),
              child: Container(
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: Theme.of(context).colorScheme.primary,
                      // 2. Parlama yarıçapını 1000'den 50'ye düşür
                      blurRadius: 500.0,
                      // 3. Yayılmayı biraz azalt
                      spreadRadius: 2.0,
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildAnimatedCorners() {
    final cornerWidth = 5.0;
    final cornerLength = 40.0;

    return Positioned.fill(
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          return Stack(
            children: [
              Positioned(
                top:
                    MediaQuery.of(context).size.height * 0.42 -
                    _getCornerOffset(),
                left:
                    MediaQuery.of(context).size.width * 0.5 -
                    _getCornerOffset(),
                child: Opacity(
                  opacity: 0.7 + (_animation.value * 0.1),
                  child: Container(
                    width: cornerLength,
                    height: cornerLength,
                    decoration: BoxDecoration(
                      border: Border(
                        top: BorderSide(
                          color: Theme.of(context).colorScheme.primary,
                          width: cornerWidth,
                        ),
                        left: BorderSide(
                          color: Theme.of(context).colorScheme.primary,
                          width: cornerWidth,
                        ),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Theme.of(context).colorScheme.primary,
                          blurRadius: 10,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Positioned(
                top:
                    MediaQuery.of(context).size.height * 0.42 -
                    _getCornerOffset(),
                right:
                    MediaQuery.of(context).size.width * 0.5 -
                    _getCornerOffset(),
                child: Opacity(
                  opacity: 0.7 + (_animation.value * 0.1),
                  child: Container(
                    width: cornerLength,
                    height: cornerLength,
                    decoration: BoxDecoration(
                      border: Border(
                        top: BorderSide(
                          color: Theme.of(context).colorScheme.primary,
                          width: cornerWidth,
                        ),
                        right: BorderSide(
                          color: Theme.of(context).colorScheme.primary,
                          width: cornerWidth,
                        ),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Theme.of(context).colorScheme.primary,
                          blurRadius: 10,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom:
                    MediaQuery.of(context).size.height * 0.58 -
                    _getCornerOffset(),
                left:
                    MediaQuery.of(context).size.width * 0.5 -
                    _getCornerOffset(),
                child: Opacity(
                  opacity: 0.7 + (_animation.value * 0.1),
                  child: Container(
                    width: cornerLength,
                    height: cornerLength,
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: Theme.of(context).colorScheme.primary,
                          width: cornerWidth,
                        ),
                        left: BorderSide(
                          color: Theme.of(context).colorScheme.primary,
                          width: cornerWidth,
                        ),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Theme.of(context).colorScheme.primary,
                          blurRadius: 10,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom:
                    MediaQuery.of(context).size.height * 0.58 -
                    _getCornerOffset(),
                right:
                    MediaQuery.of(context).size.width * 0.5 -
                    _getCornerOffset(),
                child: Opacity(
                  opacity: 0.7 + (_animation.value * 0.1),
                  child: Container(
                    width: cornerLength,
                    height: cornerLength,
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: Theme.of(context).colorScheme.primary,
                          width: cornerWidth,
                        ),
                        right: BorderSide(
                          color: Theme.of(context).colorScheme.primary,
                          width: cornerWidth,
                        ),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Theme.of(context).colorScheme.primary,
                          blurRadius: 10,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildInstructions() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Text(
        AppLocalizations.of(context)!.alignQrCode,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: Colors.white.withValues(alpha: 0.9),
          fontSize: 15,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.5,
          shadows: [
            Shadow(
              offset: const Offset(0, 1),
              blurRadius: 10,
              color: Colors.black.withValues(alpha: 0.8),
            ),
          ],
        ),
      ),
    );
  }

  void _onDetect(BarcodeCapture capture) {
    if (!_isScanning) return;

    final List<Barcode> barcodes = capture.barcodes;

    for (final barcode in barcodes) {
      if (barcode.rawValue != null) {
        setState(() {
          _isScanning = false;
        });

        cameraController.stop();
        Navigator.pop(context, barcode.rawValue);
        break;
      }
    }
  }
}

class AdvancedScannerPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black.withValues(alpha: 0.75)
      ..style = PaintingStyle.fill;

    final screenWidth = size.width;
    final screenHeight = size.height;
    final cutOutSize = (screenWidth * 0.7).clamp(200.0, 350.0);

    final centerX = screenWidth / 2;
    final centerY = screenHeight * 0.42;

    final cutOutRect = Rect.fromCenter(
      center: Offset(centerX, centerY),
      width: cutOutSize,
      height: cutOutSize,
    );

    final cutOutPath = Path()
      ..addRRect(
        RRect.fromRectAndRadius(cutOutRect, const Radius.circular(20)),
      );

    final fullScreenPath = Path()
      ..addRect(Rect.fromLTWH(0, 0, screenWidth, screenHeight));

    final overlayPath = Path.combine(
      PathOperation.difference,
      fullScreenPath,
      cutOutPath,
    );

    canvas.drawPath(overlayPath, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
