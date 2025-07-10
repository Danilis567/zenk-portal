// lib/models/stock_item_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class StockItemModel {
  final String id;
  final String itemName;
  final int quantity;
  final String imageUrl;

  StockItemModel({
    required this.id,
    required this.itemName,
    required this.quantity,
    required this.imageUrl,
  });

  factory StockItemModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return StockItemModel(
      id: doc.id,
      itemName: data['itemName'] ?? 'İsimsiz Ürün',
      quantity: (data['quantity'] ?? 0) as int,
      imageUrl: data['imageUrl'] ?? '',
    );
  }
}