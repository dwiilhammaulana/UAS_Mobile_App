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
