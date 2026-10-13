import 'package:flutter/material.dart';

import 'theme/app_theme.dart';
import 'screens/landing_page.dart';
import 'screens/login_page.dart';
import 'screens/dashboard_page.dart';
import 'screens/users_page.dart';
import 'screens/lotes_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AVISENA COL',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      initialRoute: '/',
      routes: {
        '/': (context) => const LandingPage(),
        '/login': (context) => const LoginPage(),
        '/dashboard': (context) => const DashboardPage(),
        '/users': (context) => const UsersPage(),
        '/lotes': (context) => const LotesPage(),
      },
    );
  }
}
