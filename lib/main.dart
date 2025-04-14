import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'dart:html' as html;
import 'package:http/http.dart' as http;
import 'package:notificacion_factura/confirmar_descarga.dart';
import 'package:notificacion_factura/loading.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Factura Expirada',

      theme: ThemeData(
        primarySwatch: Colors.teal,
        fontFamily: 'Roboto',
        brightness: Brightness.light,
        primaryColor: Colors.blueAccent,
      ),
      darkTheme: ThemeData(
        primarySwatch: Colors.teal,
        fontFamily: 'Roboto',
        brightness: Brightness.dark,
        primaryColor: Colors.blueAccent,
      ),
      themeMode: ThemeMode.system,
      home: const ExpiredInvoiceScreen(),
    );
  }
}

class ExpiredInvoiceScreen extends StatefulWidget {
  const ExpiredInvoiceScreen({super.key});

  @override
  State<ExpiredInvoiceScreen> createState() => _ExpiredInvoiceScreenState();
}

class _ExpiredInvoiceScreenState extends State<ExpiredInvoiceScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _clockController;
  late Animation<double> _clockRotationAnimation;
  bool _verificando = true;
  bool descargada = false;

  @override
  void initState() {
    super.initState();

    // Setup animation for the clock icon
    _clockController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _clockRotationAnimation = Tween<double>(begin: -0.05, end: 0.05).animate(
      CurvedAnimation(parent: _clockController, curve: Curves.easeInOut),
    );

    _verificarFactura();
  }

  @override
  void dispose() {
    _clockController.dispose();
    super.dispose();
  }

  Future<void> _verificarFactura() async {
    final encoded = Uri.base.queryParameters['url'];
    final fileUrl = Uri.decodeComponent(encoded ?? '');

    if (fileUrl.isEmpty) {
      setState(() => _verificando = false);
      return;
    }

    try {
      final response = await http.head(Uri.parse(fileUrl));

      if (response.statusCode == 200) {
        html.window.location.href = fileUrl; // ✅ Redirige si existe
        setState(() => _verificando = false);
        setState(() => descargada = true);
      } else {
        print('❌ Código de estado: ${response.statusCode}');
        setState(() => _verificando = false);
      }
    } catch (e) {
      print('⚠️ Error accediendo a la URL: $e');
      setState(() => _verificando = false); // Muestra error
    }
  }

  @override
  Widget build(BuildContext context) {
    // Get screen size for responsive design
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width < 600;
    final isMediumScreen = screenSize.width >= 600 && screenSize.width < 900;

    // Calculate padding and sizes based on screen size
    final containerWidth =
        isSmallScreen
            ? screenSize.width * 0.9
            : isMediumScreen
            ? 600.0
            : 800.0;

    final padding =
        isSmallScreen
            ? 24.0
            : isMediumScreen
            ? 40.0
            : 48.0;

    final iconSize = isSmallScreen ? 60.0 : 80.0;
    final circleSize = isSmallScreen ? 120.0 : 160.0;

    if (_verificando) {
      return VerifyingDataScreen();
    } else if (descargada) {
      return InvoiceDownloadedScreen();
    }

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFF9FAFB), Color(0xFFF3F4F6)],
          ),
        ),
        child: Center(
          child: TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0, end: 1),
            duration: const Duration(milliseconds: 500),
            builder: (context, value, child) {
              return Opacity(
                opacity: value,
                child: Transform.translate(
                  offset: Offset(0, 20 * (1 - value)),
                  child: child,
                ),
              );
            },
            child: Container(
              width: containerWidth,
              padding: EdgeInsets.all(padding),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 20,
                    spreadRadius: 5,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Stack(
                alignment: Alignment.center,
                clipBehavior: Clip.none,
                children: [
                  // Background decorative circles
                  Positioned(
                    top: -80,
                    right: -80,
                    child: Container(
                      width: 200,
                      height: 200,
                      decoration: BoxDecoration(
                        color: Colors.grey[100]!.withOpacity(0.5),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: -60,
                    left: -60,
                    child: Container(
                      width: 150,
                      height: 150,
                      decoration: BoxDecoration(
                        color: Colors.grey[100]!.withOpacity(0.3),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),

                  // Content
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Clock icon with animation
                      TweenAnimationBuilder<double>(
                        tween: Tween<double>(begin: 0, end: 1),
                        duration: const Duration(milliseconds: 500),
                        curve: Curves.elasticOut,
                        builder: (context, value, child) {
                          return Transform.scale(scale: value, child: child);
                        },
                        child: Container(
                          width: circleSize,
                          height: circleSize,
                          decoration: BoxDecoration(
                            color: Colors.blueAccent[50],
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: AnimatedBuilder(
                              animation: _clockRotationAnimation,
                              builder: (context, child) {
                                return Transform.rotate(
                                  angle:
                                      _clockRotationAnimation.value * math.pi,
                                  child: Icon(
                                    Icons.access_time,
                                    size: iconSize,
                                    color: Colors.blueAccent[500],
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Title with fade animation
                      TweenAnimationBuilder<double>(
                        tween: Tween<double>(begin: 0, end: 1),
                        duration: const Duration(milliseconds: 500),
                        curve: Curves.easeOut,
                        builder: (context, value, child) {
                          return Opacity(
                            opacity: value,
                            child: Transform.translate(
                              offset: Offset(0, 10 * (1 - value)),
                              child: child,
                            ),
                          );
                        },
                        child: Text(
                          '🕒 La factura ha expirado',
                          style: TextStyle(
                            fontSize: isSmallScreen ? 22 : 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[800],
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),

                      const SizedBox(height: 12),

                      // First message with fade animation
                      TweenAnimationBuilder<double>(
                        tween: Tween<double>(begin: 0, end: 1),
                        duration: const Duration(milliseconds: 500),
                        curve: Curves.easeOut,
                        builder: (context, value, child) {
                          return Opacity(opacity: value, child: child);
                        },
                        child: Text(
                          'Lo sentimos, esta factura ya no está disponible.',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),

                      const SizedBox(height: 8),

                      // Second message with fade animation
                      TweenAnimationBuilder<double>(
                        tween: Tween<double>(begin: 0, end: 1),
                        duration: const Duration(milliseconds: 500),
                        curve: Curves.easeOut,
                        builder: (context, value, child) {
                          return Opacity(opacity: value, child: child);
                        },
                        child: Text(
                          'Si creés que esto es un error, comunicate con la tienda.',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[500],
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// // Custom animated button
// class _AnimatedButton extends StatefulWidget {
//   final String text;
//   final VoidCallback onPressed;

//   const _AnimatedButton({Key? key, required this.text, required this.onPressed})
//     : super(key: key);

//   @override
//   State<_AnimatedButton> createState() => _AnimatedButtonState();
// }

// class _AnimatedButtonState extends State<_AnimatedButton> {
//   bool _isPressed = false;
//   bool _isHovered = false;

//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTapDown: (_) => setState(() => _isPressed = true),
//       onTapUp: (_) => setState(() => _isPressed = false),
//       onTapCancel: () => setState(() => _isPressed = false),
//       onTap: widget.onPressed,
//       child: MouseRegion(
//         onEnter: (_) => setState(() => _isHovered = true),
//         onExit: (_) => setState(() => _isHovered = false),
//         child: AnimatedContainer(
//           duration: const Duration(milliseconds: 150),
//           padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
//           decoration: BoxDecoration(
//             borderRadius: BorderRadius.circular(30),
//             gradient: const LinearGradient(
//               colors: [Color(0xFFF59E0B), Color(0xFFD97706)],
//               begin: Alignment.centerLeft,
//               end: Alignment.centerRight,
//             ),
//             boxShadow: [
//               BoxShadow(
//                 color: Colors.blueAccent.withOpacity(_isHovered ? 0.3 : 0.2),
//                 blurRadius: _isHovered ? 8 : 4,
//                 spreadRadius: _isHovered ? 2 : 1,
//                 offset: const Offset(0, 4),
//               ),
//             ],
//           ),
//           child: Text(
//             widget.text,
//             style: const TextStyle(
//               color: Colors.white,
//               fontWeight: FontWeight.w500,
//               fontSize: 16,
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
