// lib/models/order_model.dart (SIFIRDAN)
import 'package:cloud_firestore/cloud_firestore.dart';

class OrderModel {
  final String id;
  final String customerName;
  final String status;
  final Timestamp createdAt;
  final FinalProduct finalProduct;
  final List<RequiredComponent> requiredComponents;
  final List<StatusHistoryItem> statusHistory;

  OrderModel({
    required this.id,
    required this.customerName,
    required this.status,
    required this.createdAt,
    required this.finalProduct,
    required this.requiredComponents,
    required this.statusHistory,
  });

  factory OrderModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    var componentsList = data['requiredComponents'] as List<dynamic>? ?? [];
    List<RequiredComponent> components =
    componentsList.map((item) => RequiredComponent.fromMap(item)).toList();

    var historyList = data['statusHistory'] as List<dynamic>? ?? [];
    List<StatusHistoryItem> history =
    historyList.map((item) => StatusHistoryItem.fromMap(item)).toList();

    return OrderModel(
      id: doc.id,
      customerName: data['customerName'] ?? '',
      status: data['status'] ?? 'Bilinmiyor',
      createdAt: data['createdAt'] ?? Timestamp.now(),
      finalProduct: FinalProduct.fromMap(data['finalProduct'] ?? {}),
      requiredComponents: components,
      statusHistory: history,
    );
  }
}

class FinalProduct {
  final String productName;
  final String notes;
  final int quality;

  FinalProduct({
    required this.productName,
    required this.notes,
    required this.quality,
  });

  factory FinalProduct.fromMap(Map<String, dynamic> map) {
    return FinalProduct(
      productName: map['productName'] ?? '',
      notes: map['notes'] ?? '',
      quality: map['quality'] ?? 0,
    );
  }
}

class RequiredComponent {
  final String itemId;
  final String itemName;
  final int quantityUsed;

  RequiredComponent({
    required this.itemId,
    required this.itemName,
    required this.quantityUsed,
  });

  factory RequiredComponent.fromMap(Map<String, dynamic> map) {
    return RequiredComponent(
      itemId: map['itemId'] ?? '',
      itemName: map['itemName'] ?? '',
      quantityUsed: map['quantityUsed'] ?? 0,
    );
  }
}

class StatusHistoryItem {
  final String status;
  final Timestamp timestamp;

  StatusHistoryItem({required this.status, required this.timestamp});

  factory StatusHistoryItem.fromMap(Map<String, dynamic> map) {
    return StatusHistoryItem(
      status: map['status'] ?? 'bilinmiyor',
      timestamp: map['timestamp'] ?? Timestamp.now(),
    );
  }
}