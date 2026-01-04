import 'package:flutter/material.dart';
import 'package:uas_mobile_app/page/login.dart';
import 'package:uas_mobile_app/page/splash_screen1.dart';

class SplashPageGlobal extends StatelessWidget {
  const SplashPageGlobal({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold();
  }
}

return Scaffold(
  backgroundColor: const Color(0xFFFFC107),
);

body: Stack(
  children: [],
),

ClipPath(
  clipper: TopCurveClipper(),
  child: Container(
    height: 300,
    width: double.infinity,
    color: const Color(0xFF111827),
  ),
),

SafeArea(
  child: Container(),
),
SafeArea(
  child: Padding(
    padding: const EdgeInsets.all(20),
    child: Column(
      children: [],
    ),
  ),
),
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

Expanded(
  child: Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [],
  ),
),
