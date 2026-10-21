import 'package:flutter/material.dart';

import '../../core/models/app_bootstrap.dart';
import 'restaurant_service.dart';

class RestaurantHomePage extends StatefulWidget {
  final AppBootstrap bootstrap;

  const RestaurantHomePage({super.key, required this.bootstrap});

  @override
  State<RestaurantHomePage> createState() => _RestaurantHomePageState();
}

class _RestaurantHomePageState extends State<RestaurantHomePage> {
  bool loading = true;
  String? error;
  List<Map<String, dynamic>> items = [];

  int? get organizationId {
    final workspace = widget.bootstrap.activeWorkspace;
    final value = workspace['organization_id'] ?? workspace['id'];
    final id = int.tryParse(value?.toString() ?? '');
    return id != null && id > 0 ? id : null;
  }

  @override
  void initState() {
    super.initState();
    loadMenu();
  }

  Future<void> loadMenu() async {
    final orgId = organizationId;

    if (orgId == null) {
      setState(() {
        loading = false;
        error = 'ไม่พบ Organization ID ของร้าน';
      });
      return;
    }

    setState(() {
      loading = true;
      error = null;
    });

    try {
      final result = await RestaurantService.getMenu(orgId);

      if (!mounted) return;

      setState(() {
        items = result;
        loading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        loading = false;
        error = e.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  Future<void> editPrice(Map<String, dynamic> item) async {
    final controller = TextEditingController(text: item['price'].toString());

    final price = await showDialog<double>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('แก้ราคา: ${item['name']}'),
        content: TextField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(
            labelText: 'ราคา (บาท)',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('ยกเลิก'),
          ),
          FilledButton(
            onPressed: () {
              final value = double.tryParse(controller.text.trim());
              if (value == null ||
                  !value.isFinite ||
                  value < 0 ||
                  value >= 100000000) {
                return;
              }
              Navigator.pop(dialogContext, value);
            },
            child: const Text('บันทึก'),
          ),
        ],
      ),
    );

    controller.dispose();

    if (price == null || !mounted) return;

    try {
      await RestaurantService.updatePrice(
        organizationId: organizationId!,
        menuId: int.parse(item['id'].toString()),
        price: price,
      );

      await loadMenu();
    } catch (e) {
      showError(e);
    }
  }

  Future<void> changeAvailability(
    Map<String, dynamic> item,
    bool available,
  ) async {
    try {
      await RestaurantService.setAvailability(
        organizationId: organizationId!,
        menuId: int.parse(item['id'].toString()),
        available: available,
      );

      await loadMenu();
    } catch (e) {
      showError(e);
    }
  }

  void showError(Object error) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(error.toString().replaceFirst('Exception: ', ''))),
    );
  }

  @override
  Widget build(BuildContext context) {
    final availableCount = items
        .where((item) => item['is_available'].toString() == '1')
        .length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('จัดการเมนูอาหาร'),
        actions: [
          IconButton(
            tooltip: 'โหลดข้อมูลใหม่',
            onPressed: loading ? null : loadMenu,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : error != null
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(error!),
                  const SizedBox(height: 12),
                  FilledButton(
                    onPressed: loadMenu,
                    child: const Text('ลองอีกครั้ง'),
                  ),
                ],
              ),
            )
          : RefreshIndicator(
              onRefresh: loadMenu,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'รายการอาหารของร้าน',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'ทั้งหมด ${items.length} เมนู '
                            '· พร้อมขาย $availableCount เมนู',
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (items.isEmpty)
                    const Padding(
                      padding: EdgeInsets.all(24),
                      child: Center(child: Text('ยังไม่มีรายการอาหาร')),
                    ),
                  for (final item in items)
                    Card(
                      child: ListTile(
                        title: Text(item['name']?.toString() ?? ''),
                        subtitle: Text('ราคา ${item['price']} บาท'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              tooltip: 'แก้ไขราคา',
                              icon: const Icon(Icons.edit_outlined),
                              onPressed: () => editPrice(item),
                            ),
                            Switch(
                              value: item['is_available'].toString() == '1',
                              onChanged: (value) =>
                                  changeAvailability(item, value),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
    );
  }
}
