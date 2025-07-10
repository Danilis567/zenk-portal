// lib/screens/order_tracking_detail_screen.dart (WEB İÇİN ORTALANMIŞ VERSİYON)
import 'package:flutter/foundation.dart' show kIsWeb; // kIsWeb kontrolü için import
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:zenk_app/models/order_model.dart';

class OrderTrackingDetailScreen extends StatelessWidget {
  final OrderModel order;
  const OrderTrackingDetailScreen({super.key, required this.order});

  String _formatStatusString(String status) {
    if (status.isEmpty) return '';
    if (status == 'tamamlandi') return 'Tamamlandı';
    if (status == 'iptal_edildi') return 'İptal Edildi';
    return status
        .split('_')
        .map((word) => '${word[0].toUpperCase()}${word.substring(1)}')
        .join(' ');
  }

  String _formatTimestamp(DateTime date) {
    return DateFormat('d MMMM y, HH:mm', 'tr_TR').format(date);
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'imalatta':
        return Icons.precision_manufacturing_outlined;
      case 'polisajda':
        return Icons.auto_awesome_outlined;
      case 'montajda':
        return Icons.build_outlined;
      case 'kargoya_hazir':
        return Icons.local_shipping_outlined;
      case 'tamamlandi':
        return Icons.check_circle_outline;
      case 'iptal_edildi':
        return Icons.cancel_outlined;
      default:
        return Icons.hourglass_empty_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    final sortedHistory = List.from(order.statusHistory)
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));

    Widget content = ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        Card(
          child: ListTile(
            title: Text(order.finalProduct.productName,
                style: Theme.of(context).textTheme.titleLarge),
            subtitle:
            Text("Mevcut Durum: ${_formatStatusString(order.status)}"),
          ),
        ),
        const SizedBox(height: 24),
        const Text("Sipariş Geçmişi",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        ...sortedHistory.map((historyItem) {
          bool isCurrentStatus = historyItem.status == order.status;
          return Card(
            color: isCurrentStatus ? Colors.orange.shade50 : null,
            child: ListTile(
              leading: Icon(
                _getStatusIcon(historyItem.status),
                color: isCurrentStatus ? Colors.orange : Colors.grey,
                size: 30,
              ),
              title: Text(
                _formatStatusString(historyItem.status),
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isCurrentStatus ? Colors.orange.shade900 : null),
              ),
              subtitle: Text(_formatTimestamp(historyItem.timestamp.toDate())),
            ),
          );
        }).toList(),
      ],
    );

    if (kIsWeb) {
      content = Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: content,
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text("Sipariş #${order.id.substring(0, 6)}...")),
      body: content,
    );
  }
}