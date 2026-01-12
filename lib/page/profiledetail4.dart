import 'package:flutter/material.dart';

class Profiledetail4 extends StatelessWidget {
  const Profiledetail4({super.key});

  static const String nama = "Muhamad Ulin Nuha";
  static const String nim = "1123150002";
  static const String kelas = "TI-3A";

  static const List<String> skillList = [
    "Cyber security",
    "AI ENGGINER",
    "Backend Developer",
  ];

  static const List<Map<String, String>> hobiList = [
  {
    "title": "Ngoding",
    "image": "assets/images/coding.jpeg",
  },
  {
    "title": "Membaca",
    "image": "assets/images/membaca.jpeg",
  },
  {
    "title": "Reptil",
    "image": "assets/images/reptil.jpeg",
  },
  {
    "title": "Membaca",
    "image": "assets/images/menanam.jpeg",
  },
  ];



  @override
  Widget build(BuildContext context) {
    return Scaffold(
       backgroundColor: const Color(0xFFF1F5F9),
       body: Stack(
        children: [
          Container(
            height: 220,
            width: double.infinity,
            decoration: BoxDecoration(
              
            ),
          )
        ],
       ),
    );
  }
}
