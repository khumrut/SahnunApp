import 'package:flutter/material.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final modules = [
      ('Parent', Icons.family_restroom),
      ('POS', Icons.point_of_sale),
      ('Restaurant', Icons.restaurant),
      ('Delivery', Icons.delivery_dining),
      ('Attendance', Icons.fingerprint),
      ('AI Tools', Icons.auto_awesome),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Sahnun')),
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
                final module = modules[index];

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
                            module.$2,
                            size: 46,
                            color: const Color(0xFFD9B43B),
                          ),
                          const SizedBox(height: 14),
                          Text(
                            module.$1,
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
