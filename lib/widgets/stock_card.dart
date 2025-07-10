// lib/widgets/stock_card.dart
import 'package:flutter/material.dart';
import 'package:zenk_app/models/stock_item_model.dart';
import 'package:zenk_app/screens/stock_edit_screen.dart'; // Bu importu ekleyin

class StockCard extends StatelessWidget {
  final StockItemModel stockItem;
  const StockCard({super.key, required this.stockItem});

  @override
  Widget build(BuildContext context) {
    final quantityColor = stockItem.quantity < 0 ? Colors.redAccent : Colors.black87;

    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell( // Tıklama efekti ve fonksiyonu için InkWell kullanıyoruz
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => StockEditScreen(stockItem: stockItem),
            ),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              // YENİ: Hero widget'ı animasyonu sağlar
              child: Hero(
                tag: 'stock_image_${stockItem.id}', // Her resim için benzersiz bir etiket
                child: Image.network(
                  stockItem.imageUrl,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, progress) {
                    return progress == null ? child : const Center(child: CircularProgressIndicator(strokeWidth: 2));
                  },
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.grey[200],
                      child: const Icon(Icons.image_not_supported, color: Colors.grey, size: 40),
                    );
                  },
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    stockItem.itemName,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Stok: ${stockItem.quantity}',
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,

                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}