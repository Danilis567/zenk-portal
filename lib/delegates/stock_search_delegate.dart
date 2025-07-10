// lib/delegates/stock_search_delegate.dart
import 'package:flutter/material.dart';
import 'package:zenk_app/models/stock_item_model.dart';
import 'package:zenk_app/screens/stock_edit_screen.dart'; // YENİ: Düzenleme ekranını import ettik
import 'package:zenk_app/services/firestore_service.dart';

class StockSearchDelegate extends SearchDelegate {
  final FirestoreService _firestoreService = FirestoreService();

  @override
  String get searchFieldLabel => "Stokta ürün ara...";

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    if (query.trim().isEmpty) {
      return const Center(child: Text("Lütfen bir arama terimi girin."));
    }

    return FutureBuilder<List<StockItemModel>>(
      future: _firestoreService.searchStockItems(query),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(child: Text("'$query' için sonuç bulunamadı."));
        }

        final results = snapshot.data!;

        return ListView.builder(
          itemCount: results.length,
          itemBuilder: (context, index) {
            final item = results[index];
            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: ListTile(
                leading: Image.network(item.imageUrl, width: 50, height: 50, fit: BoxFit.cover),
                title: Text(item.itemName),
                subtitle: Text("Stok: ${item.quantity}"),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => StockEditScreen(stockItem: item),
                    ),
                  );
                },
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    // Bu kısmı boş bırakmaya devam edebiliriz.
    return Container();
  }
}