import 'dart:async';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:uas_mobile_app/page/home.dart';
import 'package:uas_mobile_app/page/splash_screen1.dart'; 



class IntroAnimationPage extends StatefulWidget {
  const IntroAnimationPage({super.key});

  @override
  State<IntroAnimationPage> createState() => _IntroAnimationPageState();
}

class _IntroAnimationPageState extends State<IntroAnimationPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  // Animasi Logo
  late Animation<Offset> _logoSlideAnimation;
  late Animation<double> _logoScaleAnimation;
  // Animasi Teks
  late Animation<Offset> _textSlideAnimation;
  late Animation<double> _textFadeAnimation;

  @override
  void initState() {
    super.initState();

    // Controller tetap 2 detik agar gerakan tetap lincah
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    // 1. Animasi Logo (Muncul dari bawah)
    _logoSlideAnimation = Tween<Offset>(
      begin: const Offset(0, 2.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutBack,
    ));

    _logoScaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));

    // 2. Animasi Teks NoteZy (Muncul dari kiri di akhir gerakan logo)
    _textSlideAnimation = Tween<Offset>(
      begin: const Offset(-0.3, 0.0), // Jarak geser diperpendek agar lebih halus
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.6, 1.0, curve: Curves.easeOut),
    ));

    _textFadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.6, 1.0, curve: Curves.easeIn),
    ));

    _controller.forward();

    // 3. Pengecekan navigasi dengan total waktu 3 detik
    _checkAuthAndNavigate();
  }

  void _checkAuthAndNavigate() {
    // TOTAL WAKTU 3 DETIK (2 detik animasi + 1 detik pause "Ready")
    Timer(const Duration(seconds: 3), () {
      if (!mounted) return;

      final session = Supabase.instance.client.auth.currentSession;

      Widget destination;
      if (session != null) {
        destination = const HomePage();
      } else {
        destination = const SplashPageOne();
      }

      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => destination,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
          transitionDuration: const Duration(milliseconds: 800),
        ),
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 0, 0, 0), // Latar Hitam
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // LOGO
            SlideTransition(
              position: _logoSlideAnimation,
              child: ScaleTransition(
                scale: _logoScaleAnimation,
                child: Image.asset(
                  'assets/icon/Note_Z.png',
                  width: 150,
                  height: 150,
                ),
              ),
            ),

            // JARAK SANGAT DEKAT
            const SizedBox(height: 1), 

            // TEKS NoteZy (Lobster Black)
            FadeTransition(
              opacity: _textFadeAnimation,
              child: SlideTransition(
                position: _textSlideAnimation,
                child: Text(
                  "NoteZy",
                  style: GoogleFonts.lobster(
                    color: Colors.white,
                    fontSize: 42,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}