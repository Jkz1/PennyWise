import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:penny_wise/firebase_options.dart';
import 'package:penny_wise/screens/home.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:penny_wise/screens/login.dart';
import 'package:penny_wise/theme.dart';
// import 'package:penny_wise/screens/loginGpt.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const ProviderScope(child: MainApp()));
}

// main.dart
class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  ThemeMode _themeMode = ThemeMode.dark; // Default to dark

  void _toggleTheme() {
    setState(() {
      _themeMode = (_themeMode == ThemeMode.dark)
          ? ThemeMode.light
          : ThemeMode.dark;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: FinTrackTheme.lightTheme,
      darkTheme: FinTrackTheme.darkTheme,
      themeMode: _themeMode, // Controlled by your toggle
      home: LoginPage(toggleTheme: _toggleTheme),
    );
    // home: LoginPage(),
  }
}
