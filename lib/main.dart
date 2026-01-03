import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uas_mobile_app/page/intro.dart';
// import 'package:testing_2/page/intro.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://freneyxlkefpyooynhee.supabase.co',
    anonKey: 'sb_publishable_qvWRRfqVHaXWfwsoKFrRsg_vJQLXrdE',
  );

  runApp(const MyApp());
}

// Biar aman: akses client lewat getter (dipakai setelah initialize selesai)
SupabaseClient get supabase => Supabase.instance.client;

class MyApp extends StatelessWidget {
  const MyApp({super.key});

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
