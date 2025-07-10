// lib/services/firestore_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:zenk_app/models/order_model.dart';
import 'package:zenk_app/models/stock_item_model.dart';
import 'package:zenk_app/models/user_model.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;



  Future<UserModel?> getUserData(String uid) async {
    try {
      final doc = await _db.collection('users').doc(uid).get();
      if (doc.exists) {
        return UserModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      print("Kullanıcı verisi alınırken hata: $e");
      return null;
    }
  }



  Stream<List<OrderModel>> getOrdersStream(
      {required List<String> statuses, String? searchQuery}) {
    Query query;
    if (searchQuery != null && searchQuery.isNotEmpty) {
      String lowerCaseQuery = searchQuery.toLowerCase();
      query = _db
          .collection('orders')
          .where('customerName_lowercase', isGreaterThanOrEqualTo: lowerCaseQuery)
          .where('customerName_lowercase', isLessThanOrEqualTo: '$lowerCaseQuery\uf8ff')
          .orderBy('customerName_lowercase')
          .orderBy('createdAt', descending: true);
    } else {
      query = _db
          .collection('orders')
          .where('status', whereIn: statuses)
          .orderBy('createdAt', descending: true);
    }
    return query.snapshots().map((snapshot) =>
        snapshot.docs.map((doc) => OrderModel.fromFirestore(doc)).toList());
  }




  Future<void> createOrderAndUpdateStock(Map<String, dynamic> orderData) async {
    if (_auth.currentUser == null) {
      throw Exception("Bu işlemi yapmak için giriş yapmalısınız.");
    }
    final List<Map<String, dynamic>> components =
    List.from(orderData['requiredComponents'] ?? []);
    return _db.runTransaction((transaction) async {
      final List<DocumentSnapshot> stockSnapshots = [];
      for (final component in components) {
        final stockItemRef =
        _db.collection('stock_items').doc(component['itemId']);
        final stockSnapshot = await transaction.get(stockItemRef);
        if (!stockSnapshot.exists) {
          throw Exception("${component['itemName']} stokta bulunamadı!");
        }
        stockSnapshots.add(stockSnapshot);
      }

      final orderRef = _db.collection('orders').doc();
      final Map<String, dynamic> finalOrderData = {
        ...orderData,
        'customerName_lowercase':
        (orderData['customerName'] as String).toLowerCase(),
        'createdAt': FieldValue.serverTimestamp(),
        'statusHistory': [
          {
            'status': orderData['status'],
            'timestamp': Timestamp.now()
          }
        ],
      };
      transaction.set(orderRef, finalOrderData);

      for (int i = 0; i < components.length; i++) {
        final component = components[i];
        final stockSnapshot = stockSnapshots[i];
        final num currentQuantity =
            (stockSnapshot.data() as Map)['quantity'] ?? 0;
        final num quantityToDecrement = component['quantityUsed'] ?? 0;
        transaction.update(stockSnapshot.reference,
            {'quantity': currentQuantity - quantityToDecrement});
      }
    });
  }



  Future<void> updateOrderStatus(String orderId, String newStatus) {
    if (_auth.currentUser == null) {
      throw Exception("Bu işlemi yapmak için giriş yapmalısınız.");
    }

    final newHistoryEntry = {
      'status': newStatus,
      'timestamp': Timestamp.now(), // GERÇEK ÇÖZÜM BURADA
    };

    return _db.collection('orders').doc(orderId).update({
      'status': newStatus,
      'statusHistory': FieldValue.arrayUnion([newHistoryEntry])
    });
  }

  // --- STOCK METHODS ---

  Stream<List<StockItemModel>> getStockItemsStream() {
    return _db.collection('stock_items').snapshots().map((snapshot) =>
        snapshot.docs.map((doc) => StockItemModel.fromFirestore(doc)).toList());
  }



  Future<void> addStockItem({
    required String itemName,
    required int initialQuantity,
    required String imageUrl,
  }) {
    return _db.collection('stock_items').add({
      'itemName': itemName,
      'itemName_lowercase': itemName.toLowerCase(),
      'quantity': initialQuantity,
      'imageUrl': imageUrl.isNotEmpty
          ? imageUrl
          : "https://firebasestorage.googleapis.com/v0/b/zenk-portal.appspot.com/o/placeholder.png?alt=media&token=e1c6b12d-2c2e-4b4b-8d3a-1f8d3c5b3e6c",
    });
  }

  Future<void> updateStockQuantity(String itemId, int newQuantity) {
    return _db
        .collection('stock_items')
        .doc(itemId)
        .update({'quantity': newQuantity});
  }

  Future<List<StockItemModel>> searchStockItems(String query) async {
    if (query.isEmpty) return [];

    final lowercaseQuery = query.toLowerCase();
    final snapshot = await _db
        .collection('stock_items')
        .where('itemName_lowercase', isGreaterThanOrEqualTo: lowercaseQuery)
        .where('itemName_lowercase',
        isLessThanOrEqualTo: '$lowercaseQuery\uf8ff')
        .get();
    return snapshot.docs
        .map((doc) => StockItemModel.fromFirestore(doc))
        .toList();
  }

  Future<void> submitBugReport({
    required String title,
    required String description,
  }) {
    final currentUser = _auth.currentUser;
    if (currentUser == null) {
      throw Exception("Hata bildirimi için kullanıcı girişi gereklidir.");
    }
    return _db.collection('bug_reports').add({
      'title': title,
      'description': description,
      'reportedByUid': currentUser.uid,
      'reportedByEmail': currentUser.email,
      'timestamp': FieldValue.serverTimestamp(),
      'status': 'yeni',
    });
  }


  Future<void> cancelOrder(String orderId, String reason) async {
    if (_auth.currentUser == null) {
      throw Exception("Bu işlemi yapmak için giriş yapmalısınız.");
    }

    final orderRef = _db.collection('orders').doc(orderId);
    final cancelledOrderRef = _db.collection('cancelled_orders').doc(orderId);

    return _db.runTransaction((transaction) async {
      final orderSnapshot = await transaction.get(orderRef);
      if (!orderSnapshot.exists) {
        throw Exception("İptal edilecek sipariş bulunamadı!");
      }
      final orderData = orderSnapshot.data()! as Map<String, dynamic>;

      final Map<String, dynamic> cancelledOrderData = {
        ...orderData,
        'status': 'iptal_edildi',
        'cancellationReason': reason,
        'cancelledAt': FieldValue.serverTimestamp(),
      };

      transaction.set(cancelledOrderRef, cancelledOrderData);
      transaction.delete(orderRef);

      final List<dynamic> components = orderData['requiredComponents'] ?? [];
      for (final component in components) {
        final stockRef = _db.collection('stock_items').doc(component['itemId']);
        final num quantityToReturn = component['quantityUsed'] ?? 0;
        transaction.update(
            stockRef, {'quantity': FieldValue.increment(quantityToReturn)});
      }
    });
  }




  Future<void> finishOrder(String orderId) {
    if (_auth.currentUser == null) {
      throw Exception("Bu işlemi yapmak için giriş yapmalısınız.");
    }
    final newHistoryEntry = {
      'status': 'tamamlandi',
      'timestamp': Timestamp.now(),
    };
    return _db.collection('orders').doc(orderId).update({
      'status': 'tamamlandi',
      'statusHistory': FieldValue.arrayUnion([newHistoryEntry]),
    });
  }

  Future<OrderModel?> getOrderById(String orderId) async {
    try {
      final doc = await _db.collection('orders').doc(orderId).get();
      return doc.exists ? OrderModel.fromFirestore(doc) : null;
    } catch (e) {
      print("Sipariş getirme hatası: $e");
      return null;
    }
  }


}