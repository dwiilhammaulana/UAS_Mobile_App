import 'package:flutter/material.dart';


class SplashPageThree extends StatelessWidget {
  const SplashPageThree({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFC107),
      body: Stack(
        children: [
          // Masukkan ke dalam children Stack di Tahap 1
ClipPath(
  clipper: TopCurveClipper(),
  child: Container(
    height: 300,
    width: double.infinity,
    color: const Color(0xFF111827),
  ),
),
        ],
      ),
    );
  }
}

// ini untuk buat lengkungan item diatas
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
