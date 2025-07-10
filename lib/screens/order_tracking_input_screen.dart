// lib/screens/order_tracking_input_screen.dart
import 'package:flutter/material.dart';
import 'package:zenk_app/models/order_model.dart';
import 'package:zenk_app/screens/order_tracking_detail_screen.dart';
import 'package:zenk_app/services/firestore_service.dart';

class OrderTrackingInputScreen extends StatefulWidget {
  const OrderTrackingInputScreen({super.key});

  @override
  State<OrderTrackingInputScreen> createState() => _OrderTrackingInputScreenState();
}

class _OrderTrackingInputScreenState extends State<OrderTrackingInputScreen> {
  final _orderIdController = TextEditingController();
  final _firestoreService = FirestoreService();
  bool _isLoading = false;

  Future<void> _trackOrder() async {
    final orderId = _orderIdController.text.trim();
    if (orderId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("Lütfen bir sipariş numarası girin."),
          backgroundColor: Colors.red));
      return;
    }

    setState(() { _isLoading = true; });

    try {
      final order = await _firestoreService.getOrderById(orderId);

      if (mounted) {
        if (order != null) {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => OrderTrackingDetailScreen(order: order)),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text("Bu numaraya ait bir sipariş bulunamadı."),
              backgroundColor: Colors.red));
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text("Bir hata oluştu. Lütfen tekrar deneyin."),
            backgroundColor: Colors.red));
      }
    } finally {
      if (mounted) {
        setState(() { _isLoading = false; });
      }
    }
  }

  @override
  void dispose() {
    _orderIdController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Sipariş Takibi")),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Icon(Icons.track_changes, size: 60, color: Colors.orange),
                const SizedBox(height: 16),
                const Text(
                  "Siparişinizin durumunu öğrenmek için lütfen sipariş numaranızı girin.",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 24),
                TextField(
                  controller: _orderIdController,
                  decoration: const InputDecoration(
                    labelText: "Sipariş Numarası",
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _isLoading ? null : _trackOrder,
                  style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white),
                  child: _isLoading
                      ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.white))
                      : const Text("SİPARİŞİ BUL"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}