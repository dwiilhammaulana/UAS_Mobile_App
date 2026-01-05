import 'package:flutter/material.dart';
import 'package:uas_mobile_app/page/profiledetail1.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Aplikasi Flutter Sederhana',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: profiledetail1(),
    );
  }
}