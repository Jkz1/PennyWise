import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:penny_wise/firebase_options.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:penny_wise/screens/home.dart';
import 'package:penny_wise/screens/login.dart';
import 'package:penny_wise/theme.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  final SharedPreferences prefs = await SharedPreferences.getInstance();

  final bool isLoggedIn = prefs.getBool('is_logged_in') ?? false;

  runApp(ProviderScope(child: MainApp(isLoggiedIn: isLoggedIn)));
}

class MainApp extends StatefulWidget {
  bool isLoggiedIn = false;
  MainApp({super.key, required this.isLoggiedIn});

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
      home: 
      // widget.isLoggiedIn
      //     ? HomePage(toggleTheme: _toggleTheme) 
      //     : 
          LoginPage(toggleTheme: _toggleTheme),
    );
  }
}
