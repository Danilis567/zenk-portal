// lib/screens/dashboard_screen.dart
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:zenk_app/screens/add_order_screen.dart';
import 'package:zenk_app/screens/add_stock_item_screen.dart';
import 'package:zenk_app/screens/orders_screen.dart';
import 'package:zenk_app/screens/settings_screen.dart';
import 'package:zenk_app/screens/stock_screen.dart';

class DashboardScreen extends StatefulWidget {
  final String userRole;
  const DashboardScreen({super.key, required this.userRole});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    if (kIsWeb) {
      return buildDesktopLayout();
    } else {
      return buildMobileLayout();
    }
  }

  Widget buildMobileLayout() {
    final pages = [
      OrdersScreen(userRole: widget.userRole),
      const StockScreen(),
      const SettingsScreen(),
    ];

    return Scaffold(
      body: SafeArea(child: pages[_selectedIndex]),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.list_alt), label: 'Siparişler'),
          BottomNavigationBarItem(
              icon: Icon(Icons.inventory_2_outlined), label: 'Stok'),
          BottomNavigationBarItem(
              icon: Icon(Icons.settings_outlined), label: 'Ayarlar'),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.orange,
        onTap: (index) => setState(() => _selectedIndex = index),
      ),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  Widget buildDesktopLayout() {
    final pages = [
      OrdersScreen(userRole: widget.userRole),
      const StockScreen(),
      const SettingsScreen(),
    ];

    return Scaffold(
      body: Row(
        children: [
          NavigationRail(
            selectedIndex: _selectedIndex,
            onDestinationSelected: (index) => setState(() => _selectedIndex = index),
            labelType: NavigationRailLabelType.all,
            leading: Padding(
              padding: const EdgeInsets.symmetric(vertical: 20.0),
              child: _buildFloatingActionButton(),
            ),
            destinations: const <NavigationRailDestination>[
              NavigationRailDestination(
                  icon: Icon(Icons.list_alt_outlined),
                  selectedIcon: Icon(Icons.list_alt),
                  label: Text('Siparişler')),
              NavigationRailDestination(
                  icon: Icon(Icons.inventory_2_outlined),
                  selectedIcon: Icon(Icons.inventory_2),
                  label: Text('Stok')),
              NavigationRailDestination(
                  icon: Icon(Icons.settings_outlined),
                  selectedIcon: Icon(Icons.settings),
                  label: Text('Ayarlar')),
            ],
          ),
          const VerticalDivider(thickness: 1, width: 1),
          Expanded(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1200),
                child: pages[_selectedIndex],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget? _buildFloatingActionButton() {
    if (widget.userRole != 'yönetici') return null;

    if (_selectedIndex == 0) {
      return FloatingActionButton(
        onPressed: () => Navigator.push(context,
            MaterialPageRoute(builder: (context) => const AddOrderScreen())),
        tooltip: 'Yeni Sipariş Ekle',
        backgroundColor: Colors.orange,
        child: const Icon(Icons.add, color: Colors.white),
      );
    } else if (_selectedIndex == 1) {
      return FloatingActionButton(
        onPressed: () => Navigator.push(context,
            MaterialPageRoute(builder: (context) => const AddStockItemScreen())),
        tooltip: 'Yeni Stok Ekle',
        backgroundColor: Colors.blueAccent,
        child: const Icon(Icons.add_shopping_cart, color: Colors.white),
      );
    }
    return null;
  }
}