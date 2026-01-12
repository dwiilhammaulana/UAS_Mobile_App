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
              gradient: LinearGradient(
                colors: [
                 Color(0xFF0F172A),
                  Color(0xFF1E293B),
                ]
                ), 
            ),
          ),

          SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(16, 120, 16, 24),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [ 
                      BoxShadow(
                       color: Colors.black.withOpacity(0.08),
                        blurRadius: 18,
                        offset: const Offset(0, 10),
                    ),
                    ],
                  ),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 52,
                        backgroundColor: const Color(0xFFE2E8F0),
                        child: CircleAvatar(
                          radius: 48,
                          backgroundImage:
                              const AssetImage("assets/images/nuha.png"),
                        ),
                      ),

                      const SizedBox(height: 24),

                      Text(
                        nama,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        kelas,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    children: [
                      _infoTile(
                        icon: Icons.person,
                        title: "Nama Lengkap",
                        value: nama,
                      ),
                       _infoTile(
                        icon: Icons.person,
                        title: "Nim",
                        value: nim,
                      ),
                       _infoTile(
                        icon: Icons.person,
                        title: "Kelas",
                        value: kelas,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Keahlian",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 12),
                     Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: skillList.map((skill) {
                          return Chip(
                            label: Text(skill),
                            backgroundColor:
                                const Color(0xFFCBD5E1),
                            labelStyle: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          );
                        }).toList(),
                      ),

                      const SizedBox(height: 28),

                      Text(
                  "Dibuat dengan Flutter",
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[500],
                  ),
                ),

                 const SizedBox(height: 24),

                   Container(
  width: double.infinity,
  padding: const EdgeInsets.all(18),
  decoration: BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(20),
  ),
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text(
        "Hobi",
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
      const SizedBox(height: 14),
      GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: hobiList.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1,
        ),
        itemBuilder: (context, index) {
          final hobi = hobiList[index];
          return Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              image: DecorationImage(
                image: AssetImage(hobi["image"]!),
                fit: BoxFit.cover,
              ),
            ),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    Colors.black.withOpacity(0.6),
                    Colors.transparent,
                  ],
                ),
              ),
              alignment: Alignment.bottomLeft,
              padding: const EdgeInsets.all(12),
              child: Text(
                hobi["title"]!,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          );
        },
      ),
    ],
  ),
),
                    ],
                  ),
                ),
              ],
            ),

          )
        ],
       ),
    );
  }
}
