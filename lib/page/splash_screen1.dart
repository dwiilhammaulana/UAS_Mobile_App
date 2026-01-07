import 'package:flutter/material.dart';
import 'package:uas_mobile_app/page/login.dart';
import 'package:uas_mobile_app/page/splash_screen2.dart';

class SplashPageOne extends StatelessWidget {
  const SplashPageOne({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFC107),
      body: Stack(
        children: [
          // ===== BACKGROUND HITAM MELENGKUNG =====
          ClipPath(
            clipper: TopCurveClipper(),
            child: Container(
              height: 300,
              width: double.infinity,
              color: const Color(0xFF111827),
            ),
          ),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ===== HEADER (TANPA ICON BACK) =====
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const AuthScreen(),
                            ),
                          );
                        },
                        child: const Text(
                          "Skip",
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 40),

                  // ===== TEXT =====
                  const Text(
                    "Terlalu banyak Job",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 10),
                  const Text(
                    "Terlalu banyak rencana dan catatan yang tersebar di mana-mana membuat semuanya terasa tidak terkendali.",
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),

                  // ===== GAMBAR =====
                  const SizedBox(height: 30),
                  Expanded(
                    child: Align(
                      alignment: Alignment.topCenter,
                      child: FractionallySizedBox(
                        widthFactor: 0.9,
                        child: Image.asset(
                          'assets/images/1.png',
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ),

                  // ===== INDIKATOR + NEXT (TETAP ADA) =====
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(children: [_dot(true), _dot(false), _dot(false)]),
                      CircleAvatar(
                        radius: 26,
                        backgroundColor: Colors.black,
                        child: IconButton(
                          icon: const Icon(
                            Icons.arrow_forward,
                            color: Colors.white,
                          ),
                          onPressed: () {
                            Navigator.pushReplacement(
                              context,
                              PageRouteBuilder(
                                pageBuilder: (_, __, ___) =>
                                    const SplashPageTwo(),
                                transitionsBuilder:
                                    (_, animation, __, child) {
                                  return FadeTransition(
                                    opacity: animation,
                                    child: child,
                                  );
                                },
                                transitionDuration:
                                    const Duration(milliseconds: 200),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  static Widget _dot(bool active) {
    return Container(
      margin: const EdgeInsets.only(right: 6),
      width: active ? 10 : 6,
      height: 6,
      decoration: BoxDecoration(
        color: active ? Colors.black : const Color.fromARGB(96, 0, 0, 0),
        borderRadius: BorderRadius.circular(10),
      ),
    );
  }
}

/// ===== CUSTOM CLIPPER =====
class TopCurveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.lineTo(0, size.height - 60);
    path.quadraticBezierTo(
      size.width / 2,
      size.height + 40,
      size.width,
      size.height - 60,
    );
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
