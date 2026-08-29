import 'package:flutter/material.dart';

import '../../core/auth/auth_service.dart';
import '../../core/models/app_bootstrap.dart';
import '../../core/auth/login_page.dart';

class DashboardPage extends StatelessWidget {
  final AppBootstrap bootstrap;

  const DashboardPage({super.key, required this.bootstrap});

  static const moduleInfo = {
    'dashboard': ('Dashboard', Icons.dashboard_outlined),
    'ai': ('AI Tools', Icons.auto_awesome),
    'photoprint': ('PhotoPrint', Icons.photo_library_outlined),
    'slidemaker': ('SlideMaker', Icons.slideshow),
    'parent': ('Parent', Icons.family_restroom),
    'pos': ('POS', Icons.point_of_sale),
    'restaurant': ('Restaurant', Icons.restaurant),
    'delivery': ('Delivery', Icons.delivery_dining),
    'attendance': ('Attendance', Icons.fingerprint),
    'wallet': ('Wallet', Icons.account_balance_wallet_outlined),
  };

  @override
  Widget build(BuildContext context) {
    final modules = bootstrap.modules
        .where((code) => moduleInfo.containsKey(code))
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sahnun'),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Center(child: Text(bootstrap.displayName)),
          ),

          IconButton(
            tooltip: 'ออกจากระบบ',
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await AuthService.logout();

              if (!context.mounted) {
                return;
              }

              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const LoginPage()),
                (_) => false,
              );
            },
          ),
        ],
      ),

      body: Padding(
        padding: const EdgeInsets.all(24),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final columns = constraints.maxWidth > 1000
                ? 4
                : constraints.maxWidth > 650
                ? 3
                : 2;

            return GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: columns,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.25,
              ),
              itemCount: modules.length,
              itemBuilder: (context, index) {
                final code = modules[index];

                final info = moduleInfo[code]!;

                return Card(
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () {},
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            info.$2,
                            size: 46,
                            color: const Color(0xFFD9B43B),
                          ),
                          const SizedBox(height: 14),
                          Text(
                            info.$1,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
