import 'package:flutter/material.dart';

class Orderpage extends StatefulWidget {
  const Orderpage({super.key});

  @override
  State<Orderpage> createState() => _OrderpageState();
}

class _OrderpageState extends State<Orderpage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
      
        body: Column(
          children: <Widget>[
            Material(
              color: Colors.white, // Arka plan rengini belirleyin
              child: TabBar(
                controller: _tabController,
                indicatorColor: Colors.orange,
                labelColor: Colors.orange,
                unselectedLabelColor: Colors.black54,
                tabs: [
                  Tab(text: 'Siparişler'),
                  Tab(text: 'Geçmiş Siparişler'),
                ],
              ),
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  Center(child: Text('Güncel Siparişler İçeriği Burada')),
                  Center(child: Text('Geçmiş Siparişler İçeriği Burada')),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
