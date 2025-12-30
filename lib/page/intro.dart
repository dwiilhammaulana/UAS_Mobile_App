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


