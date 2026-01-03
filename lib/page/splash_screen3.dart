import 'package:flutter/material.dart';
import 'package:uas_mobile_app/page/login.dart';

class SplashPageThree extends StatelessWidget {
  const SplashPageThree({super.key});

static Widget _dot(bool active) {
  return Container(
    margin: const EdgeInsets.only(right: 6),
    width: active ? 10 : 6,
    height: 6,
    decoration: BoxDecoration(
      color: active ? Colors.black : Colors.black38,
      borderRadius: BorderRadius.circular(10),
    ),
  );
}

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
                        ),
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

                  Row(
  mainAxisAlignment: MainAxisAlignment.spaceBetween,
  children: [
    Row(children: [_dot(false), _dot(false), _dot(true)]),
    CircleAvatar(
      radius: 26,
      backgroundColor: Colors.black,
      child: IconButton(
        icon: const Icon(Icons.arrow_forward, color: Colors.white),
        onPressed: () {
          Navigator.pushReplacement(
            context,
            PageRouteBuilder(
              pageBuilder: (_, __, ___) => const AuthScreen(),
              transitionsBuilder: (_, animation, __, child) {
                return FadeTransition(opacity: animation, child: child);
              },
              transitionDuration: const Duration(milliseconds: 200),
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
