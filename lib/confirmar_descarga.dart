import 'dart:math' as math;

import 'package:flutter/material.dart';

class InvoiceDownloadedScreen extends StatefulWidget {
  const InvoiceDownloadedScreen({Key? key}) : super(key: key);

  @override
  State<InvoiceDownloadedScreen> createState() =>
      _InvoiceDownloadedScreenState();
}

class _InvoiceDownloadedScreenState extends State<InvoiceDownloadedScreen>
    with TickerProviderStateMixin {
  late AnimationController _checkmarkController;
  late AnimationController _scaleController;
  late AnimationController _celebrationController;
  late Animation<double> _checkmarkAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    // Animation for the checkmark drawing
    _checkmarkController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _checkmarkAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _checkmarkController, curve: Curves.easeInOut),
    );

    // Animation for the success circle scaling
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.elasticOut),
    );

    // Animation for the celebration particles
    _celebrationController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    );

    // Start animations in sequence
    _scaleController.forward().then((_) {
      _checkmarkController.forward().then((_) {
        _celebrationController.forward();
      });
    });
  }

  @override
  void dispose() {
    _checkmarkController.dispose();
    _scaleController.dispose();
    _celebrationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Get screen size for responsive design
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width < 600;
    final brightness = Theme.of(context).brightness;
    final isDark = brightness == Brightness.dark;

    // Calculate sizes based on screen dimensions
    final circleSize = isSmallScreen ? screenSize.width * 0.4 : 240.0;

    // Colors based on theme
    final primaryColor = Theme.of(context).primaryColor;
    final backgroundColor = isDark ? const Color(0xFF121212) : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black87;
    final secondaryTextColor = isDark ? Colors.white70 : Colors.black54;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors:
                isDark
                    ? [const Color(0xFF1A1A1A), const Color(0xFF0A0A0A)]
                    : [const Color(0xFFF8F9FA), const Color(0xFFF1F3F5)],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              // Celebration particles
              AnimatedBuilder(
                animation: _celebrationController,
                builder: (context, child) {
                  return CustomPaint(
                    size: Size(screenSize.width, screenSize.height),
                    painter: CelebrationPainter(
                      animation: _celebrationController.value,
                      colors: [
                        primaryColor,
                        primaryColor.withGreen(
                          (primaryColor.green + 40).clamp(0, 255),
                        ),
                        primaryColor.withRed(
                          (primaryColor.red + 40).clamp(0, 255),
                        ),
                      ],
                    ),
                  );
                },
              ),

              // Main content
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Success animation
                    AnimatedBuilder(
                      animation: Listenable.merge([
                        _scaleAnimation,
                        _checkmarkAnimation,
                      ]),
                      builder: (context, child) {
                        return Transform.scale(
                          scale: _scaleAnimation.value,
                          child: Container(
                            width: circleSize,
                            height: circleSize,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: primaryColor.withOpacity(0.15),
                            ),
                            child: Center(
                              child: Container(
                                width: circleSize * 0.7,
                                height: circleSize * 0.7,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: primaryColor,
                                  boxShadow: [
                                    BoxShadow(
                                      color: primaryColor.withOpacity(0.3),
                                      blurRadius: 20,
                                      spreadRadius: 5,
                                    ),
                                  ],
                                ),
                                child: Center(
                                  child: CustomPaint(
                                    size: Size(
                                      circleSize * 0.4,
                                      circleSize * 0.4,
                                    ),
                                    painter: CheckmarkPainter(
                                      progress: _checkmarkAnimation.value,
                                      color: Colors.white,
                                      strokeWidth: 4,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 40),

                    // Success text with fade-in animation
                    FadeTransition(
                      opacity: _checkmarkAnimation,
                      child: Column(
                        children: [
                          Text(
                            '¡Factura descargada!',
                            style: TextStyle(
                              fontSize: isSmallScreen ? 24 : 32,
                              fontWeight: FontWeight.bold,
                              color: textColor,
                            ),
                            textAlign: TextAlign.center,
                          ),

                          const SizedBox(height: 16),

                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 32),
                            child: Text(
                              'Tu factura ha sido descargada correctamente y está lista para ser visualizada.',
                              style: TextStyle(
                                fontSize: isSmallScreen ? 16 : 18,
                                color: secondaryTextColor,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Custom painter for the checkmark
class CheckmarkPainter extends CustomPainter {
  final double progress;
  final Color color;
  final double strokeWidth;

  CheckmarkPainter({
    required this.progress,
    required this.color,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokeWidth
          ..strokeCap = StrokeCap.round;

    final path = Path();

    // Calculate checkmark points
    final startPoint = Offset(size.width * 0.2, size.height * 0.5);
    final midPoint = Offset(size.width * 0.45, size.height * 0.7);
    final endPoint = Offset(size.width * 0.8, size.height * 0.3);

    // Draw first part of checkmark (start to mid)
    if (progress < 0.5) {
      final adjustedProgress = progress * 2;
      path.moveTo(startPoint.dx, startPoint.dy);
      path.lineTo(
        startPoint.dx + (midPoint.dx - startPoint.dx) * adjustedProgress,
        startPoint.dy + (midPoint.dy - startPoint.dy) * adjustedProgress,
      );
    } else {
      // Draw complete first part
      path.moveTo(startPoint.dx, startPoint.dy);
      path.lineTo(midPoint.dx, midPoint.dy);

      // Draw second part of checkmark (mid to end)
      final adjustedProgress = (progress - 0.5) * 2;
      path.lineTo(
        midPoint.dx + (endPoint.dx - midPoint.dx) * adjustedProgress,
        midPoint.dy + (endPoint.dy - midPoint.dy) * adjustedProgress,
      );
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// Custom painter for celebration particles
class CelebrationPainter extends CustomPainter {
  final double animation;
  final List<Color> colors;

  CelebrationPainter({required this.animation, required this.colors});

  @override
  void paint(Canvas canvas, Size size) {
    final random = math.Random(42); // Fixed seed for consistent pattern

    // Only draw particles after checkmark is complete
    if (animation < 0.1) return;

    final adjustedAnimation = (animation - 0.1) / 0.9; // Normalize to 0.0-1.0

    // Draw particles
    for (int i = 0; i < 40; i++) {
      final color = colors[i % colors.length];
      final particleSize = random.nextDouble() * 8 + 4;

      // Calculate particle position
      final angle = random.nextDouble() * 2 * math.pi;
      final radius = size.width * 0.3 * adjustedAnimation;
      final centerX = size.width / 2;
      final centerY = size.height / 2;

      final x =
          centerX + radius * math.cos(angle) * (1 + random.nextDouble() * 0.5);
      final y =
          centerY + radius * math.sin(angle) * (1 + random.nextDouble() * 0.5);

      // Calculate opacity based on animation progress
      final opacity =
          (1.0 - adjustedAnimation) * (1.0 - random.nextDouble() * 0.3);

      // Draw particle
      final paint =
          Paint()
            ..color = color.withOpacity(opacity.clamp(0.0, 1.0))
            ..style = PaintingStyle.fill;

      // Randomly choose between circle and rectangle particles
      if (random.nextBool()) {
        canvas.drawCircle(Offset(x, y), particleSize, paint);
      } else {
        canvas.drawRect(
          Rect.fromCenter(
            center: Offset(x, y),
            width: particleSize * 1.5,
            height: particleSize * 1.5,
          ),
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
