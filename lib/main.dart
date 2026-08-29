import 'package:flutter/material.dart';

import 'core/auth/login_page.dart';
import 'core/theme/app_theme.dart';

void main() {
  runApp(const SahnunApp());
}

class SahnunApp extends StatelessWidget {
  const SahnunApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sahnun',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const LoginPage(),
    );
  }
}
