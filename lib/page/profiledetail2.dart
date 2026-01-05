import 'package:flutter/material.dart';

class ProfileDetailPage extends StatelessWidget {
  const ProfileDetailPage({super.key});

  static const String nama = "Muhammad Ramzy Hidayat Siregar";
  static const String nim = "1123150076";
  static const String kelas = "TI-23-M-SE";

  static const String fotoUrl =
      "https://ui-avatars.com/api/?name=Muhammad+Ramzy+Hidayat+Siregar&background=1E3A8A&color=FFFFFF&size=256";

  static const List<String> keahlian = [
    "Flutter Basic",
    "Firebase",
    "UI / UX Design",
  ];

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
@override
Widget build(BuildContext context) {
  return Scaffold(
    backgroundColor: const Color(0xFFF1F5F9),
  );
}
return Scaffold(
  backgroundColor: const Color(0xFFF1F5F9),
  appBar: AppBar(
    elevation: 0,
    backgroundColor: const Color(0xFF3B82F6),
    foregroundColor: Colors.white,
    title: const Text(
      "Profile Mahasiswa",
      style: TextStyle(fontWeight: FontWeight.bold),
    ),
  ),
);
body: SingleChildScrollView(
  padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
  child: Column(
    children: [],
  ),
),
Column(
  children: [
    Container(
      padding: const EdgeInsets.symmetric(vertical: 24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1E3A8A), Color(0xFF60A5FA)],
        ),
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 50,
            backgroundImage: NetworkImage(fotoUrl),
          ),
          const SizedBox(height: 14),
          Text(
            nama,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    ),
  ],
),
