import 'package:flutter/material.dart';
import 'package:uas_mobile_app/page/splash_screen1.dart';

void main(){
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: true,
      home: IntroAnimationPage(),
    );
  }
}