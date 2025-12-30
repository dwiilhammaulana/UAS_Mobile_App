import 'package:flutter/material.dart';
import 'dart:async';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:testing_2/page/home.dart';
import 'package:testing_2/page/splash_screen1.dart';
class IntroAnimationPage extends StatefulWidget {
  const IntroAnimationPage({super.key});

  @override
  State<IntroAnimationPage> createState() => _IntroAnimationPageState();
}
class _IntroAnimationPageState extends State<IntroAnimationPage> {
class _IntroAnimationPageState extends State<IntroAnimationPage>
    with SingleTickerProviderStateMixin {
late AnimationController _controller;
late Animation<Offset> _logoSlideAnimation;
late Animation<double> _logoScaleAnimation;
late Animation<Offset> _textSlideAnimation;
late Animation<double> _textFadeAnimation;
@override
void initState() {
  super.initState();

  _controller = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 2),
  );
_logoSlideAnimation = Tween<Offset>(
  begin: const Offset(0, 2.0),
  end: Offset.zero,
).animate(
  CurvedAnimation(
    parent: _controller,
    curve: Curves.easeOutBack,
  ),
);
_logoScaleAnimation = Tween<double>(
  begin: 0.0,
  end: 1.0,
).animate(
  CurvedAnimation(
    parent: _controller,
    curve: Curves.easeOut,
  ),
);
_textSlideAnimation = Tween<Offset>(
  begin: const Offset(-0.3, 0.0),
  end: Offset.zero,
).animate(
  CurvedAnimation(
    parent: _controller,
    curve: const Interval(0.6, 1.0, curve: Curves.easeOut),
  ),
);
_textFadeAnimation = Tween<double>(
  begin: 0.0,
  end: 1.0,
).animate(
  CurvedAnimation(
    parent: _controller,
    curve: const Interval(0.6, 1.0, curve: Curves.easeIn),
  ),
);
_controller.forward();
_checkAuthAndNavigate();
}
void _checkAuthAndNavigate() {
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


