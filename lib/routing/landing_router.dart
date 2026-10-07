import 'package:flutter/material.dart';

import '../core/models/app_bootstrap.dart';
import '../modules/dashboard/dashboard_page.dart';
import '../modules/parent/parent_home_page.dart';

class LandingRouter {
  static Widget build(AppBootstrap bootstrap) {
    switch (bootstrap.defaultLanding) {
      case 'parent':
        return ParentHomePage(bootstrap: bootstrap);

      case 'pos':
        return ModulePlaceholderPage(
          title: 'POS',
          icon: Icons.point_of_sale,
          bootstrap: bootstrap,
        );

      case 'restaurant':
        return ModulePlaceholderPage(
          title: 'Restaurant',
          icon: Icons.restaurant,
          bootstrap: bootstrap,
        );

      case 'delivery':
        return ModulePlaceholderPage(
          title: 'Delivery',
          icon: Icons.delivery_dining,
          bootstrap: bootstrap,
        );

      default:
        return DashboardPage(bootstrap: bootstrap);
    }
  }
}

class ModulePlaceholderPage extends StatelessWidget {
  final String title;
  final IconData icon;
  final AppBootstrap bootstrap;

  const ModulePlaceholderPage({
    super.key,
    required this.title,
    required this.icon,
    required this.bootstrap,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 80, color: const Color(0xFFD9B43B)),
            const SizedBox(height: 20),
            Text(
              title,
              style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text('ผู้ใช้: ${bootstrap.displayName}'),
          ],
        ),
      ),
    );
  }
}
