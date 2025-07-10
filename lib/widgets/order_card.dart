// lib/widgets/order_card.dart
import 'package:flutter/material.dart';
import 'package:zenk_app/models/order_model.dart';
import 'package:zenk_app/screens/order_detail_screen.dart';

class OrderCard extends StatelessWidget {
  final OrderModel order;
  const OrderCard({super.key, required this.order});

  // Status metnini formatlayan yardımcı metot
  String _formatStatusString(String status) {
    if (status.isEmpty) return '';
    return status
        .split('_')
        .map((word) => '${word[0].toUpperCase()}${word.substring(1)}')
        .join(' ');
  }

  // Duruma göre renk belirleyen yardımcı metot
  Color _getStatusColor(String status) {
    switch (status) {
      case 'imalatta':
        return Colors.blue.shade700;
      case 'polisajda':
        return Colors.purple.shade700;
      case 'montajda':
        return Colors.teal.shade700;
      case 'kargoya_hazir':
        return Colors.orange.shade800;
      default:
        return Colors.grey.shade700;
    }
  }

  @override
  Widget build(BuildContext context) {
    final finalProduct = order.finalProduct;
    final statusColor = _getStatusColor(order.status);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => OrderDetailScreen(order: order),
            ),
          );
        },
        child: ListTile(
          contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          // DEĞİŞİKLİK BURADA: Image.network yerine sabit bir ikon gösteriyoruz
          leading: Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.list_alt,
              color: Colors.grey.shade600,
            ),
          ),
          title: Text(order.customerName,
              style: const TextStyle(fontWeight: FontWeight.bold)),
          subtitle: Text(finalProduct.productName,
              maxLines: 1, overflow: TextOverflow.ellipsis),
          trailing: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              _formatStatusString(order.status),
              style: TextStyle(
                  color: statusColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 11),
            ),
          ),
        ),
      ),
    );
  }
}