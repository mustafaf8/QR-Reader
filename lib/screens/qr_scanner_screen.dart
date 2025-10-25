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
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Stack(
            children: [
              MobileScanner(controller: cameraController, onDetect: _onDetect),
              _buildGradientOverlay(constraints),
              if (_isScanning) _buildAdvancedScannerOverlay(constraints),
              if (_isScanning) _buildScanningLine(constraints),
              if (_isScanning) _buildAnimatedCorners(constraints),
              Positioned(
                bottom: 40,
                left: 0,
                right: 0,
                child: _buildInstructions(),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildGradientOverlay(BoxConstraints constraints) {
    final screenHeight = constraints.maxHeight;
    final gradientHeight = (screenHeight * 0.25).clamp(80.0, 200.0);

    return Stack(
      children: [
        // Üst gradient
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: Container(
            height: gradientHeight,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.8),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
        // Alt gradient
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            height: gradientHeight,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.8),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAdvancedScannerOverlay(BoxConstraints constraints) {
    final cutOutSize = _getCutOutSize(constraints);
    return CustomPaint(painter: AdvancedScannerPainter(cutOutSize: cutOutSize));
  }

  double _getCutOutSize(BoxConstraints constraints) {
    final screenWidth = constraints.maxWidth;
    final screenHeight = constraints.maxHeight;

    // Ekran oranına göre dinamik boyut hesapla
    final aspectRatio = screenWidth / screenHeight;

    if (aspectRatio > 1.5) {
      // Çok geniş ekranlar (tablet landscape)
      return (screenWidth * 0.5).clamp(250.0, 400.0);
    } else if (aspectRatio < 0.6) {
      // Çok uzun ekranlar (katlanabilir telefon)
      return (screenWidth * 0.8).clamp(200.0, 300.0);
    } else {
      // Normal telefon ekranları
      return (screenWidth * 0.7).clamp(200.0, 350.0);
    }
  }

  double _getCornerOffset(BoxConstraints constraints) {
    return _getCutOutSize(constraints) / 2;
  }

  Widget _buildScanningLine(BoxConstraints constraints) {
    final screenWidth = constraints.maxWidth;
    final screenHeight = constraints.maxHeight;
    final cutOutSize = _getCutOutSize(constraints);
    final cornerOffset = _getCornerOffset(constraints);

    // Merkez pozisyonunu hesapla
    final centerX = screenWidth / 2;
    final centerY = screenHeight * 0.5; // Daha merkezi konumlandırma

    return Positioned(
      top: centerY - cornerOffset,
      left: centerX - cornerOffset,
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          return Opacity(
            opacity: 0.4,
            child: Container(
              width: cutOutSize,
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
                      blurRadius: 500.0,
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

  Widget _buildAnimatedCorners(BoxConstraints constraints) {
    final cornerWidth = 5.0;
    final cornerLength = 40.0;
    final screenWidth = constraints.maxWidth;
    final screenHeight = constraints.maxHeight;
    final cutOutSize = _getCutOutSize(constraints);
    final cornerOffset = _getCornerOffset(constraints);

    // Merkez pozisyonunu hesapla
    final centerX = screenWidth / 2;
    final centerY = screenHeight * 0.5;

    return Positioned.fill(
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          return Stack(
            children: [
              // Sol üst köşe
              Positioned(
                top: centerY - cornerOffset,
                left: centerX - cornerOffset,
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
              // Sağ üst köşe
              Positioned(
                top: centerY - cornerOffset,
                right: screenWidth - centerX - cornerOffset,
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
              // Sol alt köşe
              Positioned(
                bottom: screenHeight - centerY - cornerOffset,
                left: centerX - cornerOffset,
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
              // Sağ alt köşe
              Positioned(
                bottom: screenHeight - centerY - cornerOffset,
                right: screenWidth - centerX - cornerOffset,
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
  final double cutOutSize;

  AdvancedScannerPainter({required this.cutOutSize});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black.withValues(alpha: 0.75)
      ..style = PaintingStyle.fill;

    final screenWidth = size.width;
    final screenHeight = size.height;

    final centerX = screenWidth / 2;
    final centerY = screenHeight * 0.5; // Daha merkezi konumlandırma

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
