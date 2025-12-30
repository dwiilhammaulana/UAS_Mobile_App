import 'package:flutter/material.dart';
import 'package:testing_2/page/splash_screen2.dart';

class MyWidget extends StatelessWidget {
  const MyWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFC107), // kuning
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
        ],
      ),
    )
  }
}