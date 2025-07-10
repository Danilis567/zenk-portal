// lib/widgets/order_list.dart
import 'package:flutter/material.dart';
import 'package:zenk_app/models/order_model.dart';
import 'package:zenk_app/services/firestore_service.dart';
import 'package:zenk_app/widgets/order_card.dart';

class OrderList extends StatelessWidget {
  final List<String> statuses;
  final String? searchQuery; // Arama sorgusunu almak için GÜNCELLENDİ

  const OrderList({super.key, required this.statuses, this.searchQuery});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<OrderModel>>(
      // Servise arama sorgusunu da iletiyoruz
      stream: FirestoreService()
          .getOrdersStream(statuses: statuses, searchQuery: searchQuery),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(
              child: Text("Veri alınırken bir hata oluştu:\n${snapshot.error}",
                  textAlign: TextAlign.center));
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          // Arama yapılıyorsa ve sonuç yoksa farklı bir mesaj gösterelim
          if(searchQuery != null && searchQuery!.isNotEmpty) {
            return const Center(child: Text("Arama sonucu bulunamadı."));
          }
          return const Center(child: Text("Bu kategoride sipariş bulunmuyor."));
        }

        final orders = snapshot.data!;

        return ListView.builder(
          padding: const EdgeInsets.only(top: 8, bottom: 80), // Listenin en altta boşluk bırakması için
          itemCount: orders.length,
          itemBuilder: (context, index) {
            final order = orders[index];
            return OrderCard(order: order);
          },
        );
      },
    );
  }
}