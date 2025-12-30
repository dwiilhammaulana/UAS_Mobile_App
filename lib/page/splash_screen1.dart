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

        SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                  // ===== HEADER =====
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Icon(Icons.arrow_back, color: Colors.white),
                      GestureDetector(
                        onTap: () {
                          // nanti ke AuthScreen
                        },
                        child: const Text(
                          "Skip",
                          style: TextStyle(color: Colors.white70, fontSize: 14),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 40),

                  // ===== TEXT =====
                  const Text(
                    "Place order",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  
              ],
            ),
            ),
        )
        ],
      ),
    )
  }
}