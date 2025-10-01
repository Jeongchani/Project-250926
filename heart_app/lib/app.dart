import 'package:flutter/material.dart';
import 'config/theme.dart';
import 'screens/splash_screen.dart';
import 'screens/link_screen.dart';
import 'screens/home_screen.dart';
import 'screens/settings_screen.dart';

class HeartApp extends StatelessWidget {
  const HeartApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Heart App',
      debugShowCheckedModeBanner: false,
      theme: appTheme,
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/link': (context) => const LinkScreen(),
        '/home': (context) => const HomeScreen(),
        '/settings': (context) => const SettingsScreen(),
      },
    );
  }
}
