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
FractionallySizedBox(
  widthFactor: 0.8,
  child: Image.asset(
    'assets/images/global.png',
    fit: BoxFit.contain,
  ),
),
const SizedBox(height: 20),

Padding(
  padding: const EdgeInsets.symmetric(horizontal: 20),
  child: Text(
    "Aplikasi Todolist Mahasiswa\nGlobal Institute",
    textAlign: TextAlign.center,
    style: TextStyle(
      color: Colors.black87,
      fontSize: 18,
      fontWeight: FontWeight.bold,
      letterSpacing: 0.5,
      height: 1.4,
    ),
  ),
),
Row(
  mainAxisAlignment: MainAxisAlignment.spaceBetween,
  children: [
    Row(
      children: [],
    ),
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
              pageBuilder: (_, __, ___) => const SplashPageOne(),
              transitionsBuilder: (_, animation, __, child) {
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
