import 'dart:async'; 
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:alarm/alarm.dart';
import 'package:flutter/services.dart'; 

// Import halaman-halaman
import 'package:uas_mobile_app/page/intro.dart';
import 'package:uas_mobile_app/page/todo_detail.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

const AndroidNotificationChannel _androidChannel = AndroidNotificationChannel(
  'task_channel',
  'Task Notifications',
  description: 'Reminder tugas',
  importance: Importance.max,
);

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
}

// Logika membuka halaman detail saat notifikasi diklik
Future<void> _openTodoById(String? todoId) async {
  if (todoId == null || todoId.isEmpty) return;
  await Future.delayed(const Duration(milliseconds: 500));

  try {
    final supabase = Supabase.instance.client;
    final todo = await supabase
        .from('todos')
        .select('*')
        .eq('id', todoId)
        .maybeSingle();

    if (todo != null) {
      navigatorKey.currentState?.push(
        MaterialPageRoute(builder: (_) => TodoDetailPage(todo: todo)),
      );
    }
  } catch (e) {
    debugPrint("Gagal buka todo: $e");
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  // 1. Init Alarm (Wajib paling awal)
  await Alarm.init();

  await Firebase.initializeApp();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  await Supabase.initialize(
    url: 'https://freneyxlkefpyooynhee.supabase.co',
    anonKey: 'sb_publishable_qvWRRfqVHaXWfwsoKFrRsg_vJQLXrdE',
  );

  const AndroidInitializationSettings androidInit =
      AndroidInitializationSettings('@mipmap/ic_launcher');
  const InitializationSettings initSettings =
      InitializationSettings(android: androidInit);

  await flutterLocalNotificationsPlugin.initialize(
    initSettings,
    onDidReceiveNotificationResponse: (details) async {
      await _openTodoById(details.payload);
    },
  );

  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(_androidChannel);

  FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
    final notif = message.notification;
    if (notif == null) return;

    await flutterLocalNotificationsPlugin.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
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
      payload: message.data['todo_id'],
    );
  });

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  
  @override
  void initState() {
    super.initState();
    // Pantau App Lifecycle (Background/Foreground)
    WidgetsBinding.instance.addObserver(this);
    
    _setupNotifications();
    
    // Cek jika aplikasi dibuka saat alarm sedang bunyi (Cold Start)
    _stopAlarmIfRinging(); 

    // Listener Alarm
    Alarm.ringStream.stream.listen((alarmSettings) {
      debugPrint("Alarm ID ${alarmSettings.id} berbunyi. Muncul notifikasi dengan tombol STOP.");
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Jika user membuka aplikasi (Resumed) saat alarm bunyi, matikan suaranya
    // (Asumsinya kalau user sudah buka app, dia sudah sadar ada reminder)
    if (state == AppLifecycleState.resumed) {
      _stopAlarmIfRinging();
    }
  }

  /// LOGIKA BARU: Cukup matikan suara, JANGAN tutup aplikasi.
  Future<void> _stopAlarmIfRinging() async {
    try {
      final allAlarms = await Alarm.getAlarms(); 
      for (var alarm in allAlarms) {
        final isRinging = await Alarm.isRinging(alarm.id);
        if (isRinging) {
          debugPrint("User aktif -> Stop alarm ID ${alarm.id}");
          await Alarm.stop(alarm.id);
        }
      }
    } catch (e) {
      debugPrint("Error checking alarm: $e");
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
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

      final initialMessage =
          await FirebaseMessaging.instance.getInitialMessage();
      if (initialMessage != null) {
        await _openTodoById(initialMessage.data['todo_id']);
      }

      FirebaseMessaging.onMessageOpenedApp
          .listen((RemoteMessage message) async {
        await _openTodoById(message.data['todo_id']);
      });
    }
  }

  Future<void> _saveTokenToSupabase(String token) async {
    final supabase = Supabase.instance.client;
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) return;

    await supabase.from('firebase_tokens').upsert({
      'user_id': userId,
      'fcm_token': token,
      'updated_at': DateTime.now().toIso8601String(),
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey, 
      debugShowCheckedModeBanner: false,
      title: 'NoteZy',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFFFC107)),
        useMaterial3: true,
      ),
      home: const IntroAnimationPage(),
    );
  }
}