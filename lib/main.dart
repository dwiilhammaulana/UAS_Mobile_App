import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:uas_mobile_app/page/intro.dart';

// 2. Fungsi untuk menangani notifikasi saat aplikasi di background/tertutup
// Harus diletakkan di luar class (top-level function)
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print("Menangani pesan background: ${message.messageId}");
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 3. Inisialisasi Firebase
  await Firebase.initializeApp();
  
  // Set handler untuk background
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // Inisialisasi Supabase
  await Supabase.initialize(
    url: 'https://freneyxlkefpyooynhee.supabase.co',
    anonKey: 'sb_publishable_qvWRRfqVHaXWfwsoKFrRsg_vJQLXrdE', 
  );

  runApp(const MyApp());
}

final supabase = Supabase.instance.client;

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  
  @override
  void initState() {
    super.initState();
    _setupNotifications();
  }

  // 4. Fungsi untuk mengatur notifikasi
  Future<void> _setupNotifications() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;

    // Minta izin (Penting untuk Android 13+ dan iOS)
    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      // Ambil Token FCM
      String? token = await messaging.getToken();
      if (token != null) {
        _saveTokenToSupabase(token);
      }

      // LISTENER 1: Saat aplikasi sedang terbuka (Foreground)
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        print('Mendapat pesan (Foreground): ${message.notification?.title}');
        
        // Tampilkan snackbar sebagai tanda notifikasi masuk
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("${message.notification?.title}: ${message.notification?.body}"),
              backgroundColor: const Color(0xFFFFC107), // Warna kuning khas aplikasi Anda
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      });

      // LISTENER 2: Saat notifikasi diklik dan aplikasi terbuka dari background
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        print('Notifikasi diklik!');
        // Anda bisa arahkan navigasi ke halaman tertentu di sini
      });
    }
  }

  // Simpan token ke database Supabase Anda
  Future<void> _saveTokenToSupabase(String token) async {
    final userId = supabase.auth.currentUser?.id;
    if (userId != null) {
      try {
        await supabase.from('firebase_tokens').upsert({
          'user_id': userId,
          'fcm_token': token,
          'updated_at': DateTime.now().toIso8601String(),
        });
        print("Token FCM berhasil disimpan ke Supabase");
      } catch (e) {
        print("Gagal simpan token: $e");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Supabase Auth',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFFFC107)),
        useMaterial3: true,
      ),
      home: const IntroAnimationPage(),
    );
  }
}