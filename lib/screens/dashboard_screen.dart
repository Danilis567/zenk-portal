import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:zenk_app/screens/add_order_screen.dart';
import 'package:zenk_app/screens/add_stock_item_screen.dart';
// import 'package:zenk_app/screens/admin_analytics_screen.dart'; // GEÇİCİ OLARAK DEVRE DIŞI
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
    // build metodu içinde tanımla ki her build'de yeniden hesaplansın
    final bool isAdmin = widget.userRole == 'yönetici';

    if (kIsWeb) {
      return buildDesktopLayout(isAdmin);
    } else {
      return buildMobileLayout(isAdmin);
    }
  }

  Widget buildMobileLayout(bool isAdmin) {
    final List<Widget> pages = [
      OrdersScreen(userRole: widget.userRole),
      const StockScreen(),
      // if (isAdmin) const AdminAnalyticsScreen(), // GEÇİCİ OLARAK DEVRE DIŞI BIRAKILDI
      const SettingsScreen(),
    ];

    final List<BottomNavigationBarItem> navBarItems = [
      const BottomNavigationBarItem(icon: Icon(Icons.list_alt), label: 'Siparişler'),
      const BottomNavigationBarItem(icon: Icon(Icons.inventory_2_outlined), label: 'Stok'),
      // if (isAdmin) const BottomNavigationBarItem(icon: Icon(Icons.analytics_outlined), label: 'Analiz'), // GEÇİCİ OLARAK DEVRE DIŞI BIRAKILDI
      const BottomNavigationBarItem(icon: Icon(Icons.settings_outlined), label: 'Ayarlar'),
    ];

    // Sayfa sayısı ile nav item sayısı uyuşmadığı için indeksi düzeltmemiz gerekebilir.
    // Yönetici değilse ve seçili index 2 ise (eski analiz sayfası), onu 2. sayfaya (ayarlar) yönlendir.
    if (!isAdmin && _selectedIndex >= 2) {
      _selectedIndex = 2;
    }

    return Scaffold(
      body: SafeArea(child: pages[_selectedIndex]),
      bottomNavigationBar: BottomNavigationBar(
        items: navBarItems,
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.orange,
        // Önemli: type'ı fixed yap ki 3'ten fazla item olunca kaybolmasın
        type: BottomNavigationBarType.fixed,
        onTap: (index) => setState(() => _selectedIndex = index),
      ),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  Widget buildDesktopLayout(bool isAdmin) {
    final List<Widget> pages = [
      OrdersScreen(userRole: widget.userRole),
      const StockScreen(),
      // if (isAdmin) const AdminAnalyticsScreen(), // GEÇİCİ OLARAK DEVRE DIŞI BIRAKILDI
      const SettingsScreen(),
    ];

    final List<NavigationRailDestination> destinations = [
      const NavigationRailDestination(
          icon: Icon(Icons.list_alt_outlined),
          selectedIcon: Icon(Icons.list_alt),
          label: Text('Siparişler')),
      const NavigationRailDestination(
          icon: Icon(Icons.inventory_2_outlined),
          selectedIcon: Icon(Icons.inventory_2),
          label: Text('Stok')),
      // if (isAdmin) const NavigationRailDestination(
      //     icon: Icon(Icons.analytics_outlined),
      //     selectedIcon: Icon(Icons.analytics),
      //     label: Text('Analiz')), // GEÇİCİ OLARAK DEVRE DIŞI BIRAKILDI
      const NavigationRailDestination(
          icon: Icon(Icons.settings_outlined),
          selectedIcon: Icon(Icons.settings),
          label: Text('Ayarlar')),
    ];
    
    // Sayfa sayısı ile nav item sayısı uyuşmadığı için indeksi düzeltmemiz gerekebilir.
    if (!isAdmin && _selectedIndex >= 2) {
      _selectedIndex = 2;
    }

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
            destinations: destinations,
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
    // Yönetici değilse FAB gösterme
    if (!(widget.userRole == 'yönetici')) return null;

    // Analiz sayfası artık olmadığı için o kontrolü kaldırabiliriz.
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
