import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:uas_mobile_app/page/intro.dart';

// handler background
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  debugPrint("BG message: ${message.messageId}");
}

// local notifications
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

const AndroidNotificationChannel _androidChannel = AndroidNotificationChannel(
  'task_channel',
  'Task Notifications',
  description: 'Reminder tugas',
  importance: Importance.max,
);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  const AndroidInitializationSettings androidInit =
      AndroidInitializationSettings('@mipmap/ic_launcher');

  const InitializationSettings initSettings =
      InitializationSettings(android: androidInit);

  await flutterLocalNotificationsPlugin.initialize(initSettings);

  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(_androidChannel);

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

  Future<void> _setupNotifications() async {
    final messaging = FirebaseMessaging.instance;

    final settings = await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized ||
        settings.authorizationStatus == AuthorizationStatus.provisional) {
      final token = await messaging.getToken();
      if (token != null) {
        await _saveTokenToSupabase(token);
      }

      FirebaseMessaging.instance.onTokenRefresh.listen((newToken) async {
        await _saveTokenToSupabase(newToken);
      });

      // foreground: tampilkan notifikasi biasa
      FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
        final notif = message.notification;
        if (notif == null) return;

        await flutterLocalNotificationsPlugin.show(
          notif.hashCode,
          notif.title,
          notif.body,
          const NotificationDetails(
            android: AndroidNotificationDetails(
              'task_channel',
              'Task Notifications',
              channelDescription: 'Reminder tugas',
              importance: Importance.max,
              priority: Priority.high,
              icon: '@mipmap/ic_launcher',
            ),
          ),
        );
      });

      // klik notifikasi saat buka dari background
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        debugPrint("Notif clicked");
        // navigasi bisa kamu taruh di sini kalau mau
      });
    } else {
      debugPrint("Notif permission denied");
    }
  }

  Future<void> _saveTokenToSupabase(String token) async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) {
      debugPrint("User belum login, token tidak disimpan");
      return;
    }

    try {
      await supabase.from('firebase_tokens').upsert({
        'user_id': userId,
        'fcm_token': token,
        'updated_at': DateTime.now().toIso8601String(),
      });
      debugPrint("Token FCM tersimpan");
    } catch (e) {
      debugPrint("Gagal simpan token: $e");
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
