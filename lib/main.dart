import 'package:flutter/material.dart';
import 'theme/app_theme.dart';
import 'screens/splash_screen.dart';
import 'screens/admin/admin_login_screen.dart';

void main() {
  runApp(const VorexApp());
}

class VorexApp extends StatelessWidget {
  const VorexApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'VOREX',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      home: const SplashScreen(),
      routes: {
        '/admin-login': (context) => const AdminLoginScreen(),
      },
    );
  }
}
