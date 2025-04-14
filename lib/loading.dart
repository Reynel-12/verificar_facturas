import 'dart:math' as math;

import 'package:flutter/material.dart';

class VerifyingDataScreen extends StatefulWidget {
  const VerifyingDataScreen({super.key});

  @override
  State<VerifyingDataScreen> createState() => _VerifyingDataScreenState();
}

class _VerifyingDataScreenState extends State<VerifyingDataScreen>
    with TickerProviderStateMixin {
  late AnimationController _rotationController;
  late AnimationController _pulseController;
  late AnimationController _dotsController;
  late Animation<double> _pulseAnimation;

  final List<String> _loadingTexts = [
    'Conectando al servidor',
    'Verificando credenciales',
    'Procesando información',
    'Validando datos',
    'Preparando resultados',
  ];
  int _currentTextIndex = 0;

  @override
  void initState() {
    super.initState();

    // Rotation animation for the circular progress
    _rotationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();

    // Pulse animation for the outer circle
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Animation for the loading dots
    _dotsController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();

    // Change loading text every 3 seconds
    Future.delayed(const Duration(seconds: 3), () {
      _changeLoadingText();
    });
  }

  void _changeLoadingText() {
    if (!mounted) return;

    setState(() {
      _currentTextIndex = (_currentTextIndex + 1) % _loadingTexts.length;
    });

    Future.delayed(const Duration(seconds: 3), () {
      _changeLoadingText();
    });
  }

  @override
  void dispose() {
    _rotationController.dispose();
    _pulseController.dispose();
    _dotsController.dispose();
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
    final iconSize = circleSize * 0.4;

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
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Animated loading indicator
                AnimatedBuilder(
                  animation: Listenable.merge([
                    _rotationController,
                    _pulseAnimation,
                  ]),
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _pulseAnimation.value,
                      child: SizedBox(
                        width: circleSize,
                        height: circleSize,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            // Outer circle with gradient
                            Container(
                              width: circleSize,
                              height: circleSize,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    primaryColor.withOpacity(0.1),
                                    primaryColor.withOpacity(0.05),
                                  ],
                                ),
                              ),
                            ),

                            // Middle circle
                            Container(
                              width: circleSize * 0.85,
                              height: circleSize * 0.85,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: backgroundColor,
                                boxShadow: [
                                  BoxShadow(
                                    color: primaryColor.withOpacity(0.2),
                                    blurRadius: 20,
                                    spreadRadius: 5,
                                  ),
                                ],
                              ),
                            ),

                            // Rotating arc
                            Transform.rotate(
                              angle: _rotationController.value * 2 * math.pi,
                              child: CustomPaint(
                                size: Size(circleSize, circleSize),
                                painter: LoadingArcPainter(
                                  color: primaryColor,
                                  strokeWidth: 4,
                                ),
                              ),
                            ),

                            // Center icon
                            Icon(
                              Icons.shield,
                              size: iconSize,
                              color: primaryColor,
                            ),

                            // Small decorative dots
                            ...List.generate(8, (index) {
                              final angle = index * (math.pi / 4);
                              final radius = circleSize * 0.42;
                              final offset = Offset(
                                radius * math.cos(angle),
                                radius * math.sin(angle),
                              );

                              return Positioned(
                                left: circleSize / 2 + offset.dx - 3,
                                top: circleSize / 2 + offset.dy - 3,
                                child: Container(
                                  width: 6,
                                  height: 6,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: primaryColor.withOpacity(0.5),
                                  ),
                                ),
                              );
                            }),
                          ],
                        ),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 40),

                // Main text
                Text(
                  'Verificando datos',
                  style: TextStyle(
                    fontSize: isSmallScreen ? 24 : 32,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 16),

                // Animated loading text with dots
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _loadingTexts[_currentTextIndex],
                      style: TextStyle(
                        fontSize: isSmallScreen ? 16 : 18,
                        color: secondaryTextColor,
                      ),
                    ),
                    AnimatedBuilder(
                      animation: _dotsController,
                      builder: (context, child) {
                        return LoadingDots(
                          controller: _dotsController,
                          color: secondaryTextColor,
                        );
                      },
                    ),
                  ],
                ),

                const SizedBox(height: 60),

                // Progress bar
                Container(
                  width: isSmallScreen ? screenSize.width * 0.7 : 400,
                  height: 6,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(3),
                    color: isDark ? Colors.grey[800] : Colors.grey[200],
                  ),
                  child: Stack(
                    children: [
                      AnimatedBuilder(
                        animation: _rotationController,
                        builder: (context, child) {
                          return FractionallySizedBox(
                            widthFactor:
                                (_rotationController.value * 0.75) + 0.25,
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(3),
                                gradient: LinearGradient(
                                  colors: [
                                    primaryColor,
                                    primaryColor.withGreen(
                                      (primaryColor.green + 40).clamp(0, 255),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Custom painter for the loading arc
class LoadingArcPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;

  LoadingArcPainter({required this.color, required this.strokeWidth});

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromCircle(
      center: Offset(size.width / 2, size.height / 2),
      radius: size.width / 2,
    );

    final paint =
        Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokeWidth
          ..strokeCap = StrokeCap.round;

    canvas.drawArc(rect, 0, 1.5 * math.pi, false, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// Animated loading dots
class LoadingDots extends StatelessWidget {
  final AnimationController controller;
  final Color color;

  const LoadingDots({Key? key, required this.controller, required this.color})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (index) {
        final delay = index * 0.2;
        final opacity =
            math.sin((controller.value * 2 * math.pi) + delay * math.pi).abs();

        return Container(
          width: 4,
          height: 4,
          margin: const EdgeInsets.symmetric(horizontal: 2),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color.withOpacity(opacity),
          ),
        );
      }),
    );
  }
}
