import 'package:alarm/alarm.dart';
import 'package:flutter/material.dart';

class AlarmRingScreen extends StatelessWidget {
  final AlarmSettings alarmSettings;

  const AlarmRingScreen({super.key, required this.alarmSettings});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Background gelap untuk kenyamanan mata & privasi
      backgroundColor: const Color(0xFF1F2937), 
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // Ikon Lonceng Animasi (Opsional, pakai Icon biasa juga oke)
            const Center(
              child: Icon(
                Icons.alarm_on_rounded,
                color: Colors.white,
                size: 100,
              ),
            ),
            
            // Judul & Pesan
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  Text(
                    alarmSettings.notificationSettings.title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    alarmSettings.notificationSettings.body,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
            ),

            // TOMBOL MATIKAN (STOP)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: SizedBox(
                width: double.infinity,
                height: 60,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    // 1. Matikan Alarm
                    await Alarm.stop(alarmSettings.id);
                    // 2. Tutup Halaman ini (kembali ke Home/sebelumnya)
                    if (context.mounted) Navigator.pop(context);
                  },
                  icon: const Icon(Icons.stop_circle_outlined, size: 32),
                  label: const Text(
                    "MATIKAN",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(50),
                    ),
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