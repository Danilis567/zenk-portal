// lib/screens/stock_screen.dart
import 'package:flutter/foundation.dart' show kIsWeb; // kIsWeb kontrolü için
import 'package:flutter/material.dart';
import 'package:zenk_app/delegates/stock_search_delegate.dart';
import 'package:zenk_app/models/stock_item_model.dart';
import 'package:zenk_app/services/firestore_service.dart';
import 'package:zenk_app/widgets/stock_card.dart';

class StockScreen extends StatelessWidget {
  const StockScreen({super.key});

  @override
  Widget build(BuildContext context) {

    const bool isWeb = kIsWeb;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Stok Durumu"),
        elevation: 1,

        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {

              showSearch(
                context: context,
                delegate: StockSearchDelegate(),
              );
            },
          ),
        ],
      ),
      body: StreamBuilder<List<StockItemModel>>(
        stream: FirestoreService().getStockItemsStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text("Hata: ${snapshot.error}"));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("Stokta ürün bulunmuyor."));
          }

          final items = snapshot.data!;

          return GridView.builder(
            padding: const EdgeInsets.all(16.0),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: isWeb ? 3 : 2,
              crossAxisSpacing: 16.0,
              mainAxisSpacing: 16.0,
              childAspectRatio: isWeb ? 1.0 : 0.85,
            ),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              return StockCard(stockItem: item);
            },
          );
        },
      ),
    );
  }
}