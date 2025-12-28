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

// icon kembali dan skip (masih dummy)
SafeArea(
  child: Padding(
    padding: const EdgeInsets.all(20),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Icon(Icons.arrow_back, color: Colors.white),
            GestureDetector(
              onTap: () {},
              child: const Text(
                "Skip",
                style: TextStyle(color: Colors.white70, fontSize: 14),
              )
            ),
          ],
        ),
        const SizedBox(height: 40),
const Text(
  "Place order",
  style: TextStyle(
    color: Colors.white,
    fontSize: 26,
    fontWeight: FontWeight.bold,
  ),
),
const SizedBox(height: 10),
const Text(
  "Lorem ipsum dolor sit amet\nconsectetur adipiscing",
  style: TextStyle(color: Colors.white70, fontSize: 14),
),
const SizedBox(height: 30),
Expanded(
  child: Align(
    alignment: Alignment.topCenter,
    child: FractionallySizedBox(
      widthFactor: 0.9,
      child: Image.asset(
        'assets/images/3.png',
        fit: BoxFit.contain,
      ),
    ),
  ),
),
      ],
    ),
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
