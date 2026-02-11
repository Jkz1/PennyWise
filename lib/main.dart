import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:penny_wise/firebase_options.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:penny_wise/provider/darkModeProv.dart';
import 'package:penny_wise/screens/home.dart';
import 'package:penny_wise/screens/login.dart';
import 'package:penny_wise/theme.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  final SharedPreferences prefs = await SharedPreferences.getInstance();

  final bool isLoggedIn = prefs.getBool('is_logged_in') ?? false;

  runApp(ProviderScope(child: MainApp(isLoggedIn: isLoggedIn)));
}

class MainApp extends ConsumerWidget {
  final bool isLoggedIn;
  const MainApp({super.key, required this.isLoggedIn});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = ref.watch(darkmode);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'FinTrack',
      theme: FinTrackTheme.lightTheme,
      darkTheme: FinTrackTheme.darkTheme,
      themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
      home:
          isLoggedIn ? const HomePage() :
          const LoginPage(),
    );
  }
}
