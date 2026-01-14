import 'package:flutter/material.dart';

class ProfileDetail1 extends StatelessWidget {
  const ProfileDetail1({Key? key}) : super(key: key);

  static const String nama = 'Syailendra Fas Faye';
  static const String nim = '1123150198';
  static const String kelas = 'TI 23 SE M';
  static const String fotoUrl = 'assets/images/lendra.JPG';
  static const List<String> keahlian = [
    'Flutter Basic',
    'Database',
    'Administrasi',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil Mahasiswa'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const CircleAvatar(
              radius: 80,
              backgroundImage: AssetImage(fotoUrl),
            ),
            const SizedBox(height: 20),

            const Text(
              nama,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 10),

            Text(
              'NIM: $nim',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 10),

            Text(
              'Kelas: $kelas',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 20),

            const Text(
              'Keahlian:',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 10),

            Expanded(
              child: ListView.builder(
                itemCount: keahlian.length,
                itemBuilder: (context, index) {
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 5),
                    child: ListTile(
                      leading: const Icon(Icons.star, color: Colors.blue),
                      title: Text(
                        keahlian[index],
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
