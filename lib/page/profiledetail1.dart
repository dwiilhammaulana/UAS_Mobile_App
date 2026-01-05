import 'package:flutter/material.dart';

class profiledetail1 extends StatelessWidget {
  final String nama = 'Syailendra Fas Faye';
  final String nim = '1123150198';
  final String kelas = 'TI 23 SE M';
  final String fotoUrl = 'https://i.imgur.com/mwUEjfB.jpeg'; 
  final List<String> keahlian = ['Flutter Basic', 'Database', 'Administrasi'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profil Mahasiswa'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 80,
              backgroundImage: NetworkImage(fotoUrl), 
            ),
            SizedBox(height: 20),

            Text(
              nama,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 10),

             Text(
              'NIM: $nim',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[700],
              ),
            ),
            SizedBox(height: 10),

            Text(
              'Kelas: $kelas',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[700],
              ),
            ),
            SizedBox(height: 20),

            
          ],
        ),
        ),
    );
  }
}