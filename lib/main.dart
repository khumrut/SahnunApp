import 'package:flutter/material.dart';

import 'core/auth/auth_service.dart';
import 'core/auth/login_page.dart';
import 'core/theme/app_theme.dart';
import 'routing/landing_router.dart';

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
      home: const AppBootstrapPage(),
    );
  }
}

class AppBootstrapPage extends StatefulWidget {
  const AppBootstrapPage({super.key});

  @override
  State<AppBootstrapPage> createState() => _AppBootstrapPageState();
}

class _AppBootstrapPageState extends State<AppBootstrapPage> {
  @override
  void initState() {
    super.initState();
    start();
  }

  Future<void> start() async {
    final bootstrap = await AuthService.restoreSession();

    if (!mounted) {
      return;
    }

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => bootstrap == null
            ? const LoginPage()
            : LandingRouter.build(bootstrap),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('S', style: TextStyle(fontSize: 72, color: Color(0xFFD9B43B))),
            SizedBox(height: 24),
            CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
