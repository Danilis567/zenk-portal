import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:zenk_app/models/order_model.dart';
import 'package:zenk_app/services/firestore_service.dart';

class OrderDetailScreen extends StatefulWidget {
  final OrderModel order;
  const OrderDetailScreen({super.key, required this.order});

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  late String _selectedStatus;
  final FirestoreService _firestoreService = FirestoreService();
  final List<String> _statusOptions = const [
    'imalatta',
    'polisajda',
    'montajda',
    'kargoya_hazir'
  ];

  @override
  void initState() {
    super.initState();
    _selectedStatus = widget.order.status;
  }

  String _formatStatusString(String status) {
    if (status.isEmpty) return 'Bilinmiyor';
    if (status == 'tamamlandi') return 'Tamamlandı';
    return status
        .split('_')
        .map((word) => '${word[0].toUpperCase()}${word.substring(1)}')
        .join(' ');
  }

  Future<void> _updateStatus(String newStatus) async {
    try {
      await _firestoreService.updateOrderStatus(widget.order.id, newStatus);
      if (mounted) {
        setState(() {
          _selectedStatus = newStatus;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Durum güncellendi: ${_formatStatusString(newStatus)}'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Hata: Durum güncellenemedi. ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showCancelDialog() {
    final reasonController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Text("Siparişi İptal Et"),
        content: Form(
          key: formKey,
          child: TextFormField(
            controller: reasonController,
            decoration: const InputDecoration(labelText: "İptal Sebebi"),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Lütfen bir sebep girin.';
              }
              return null;
            },
          ),
        ),
        actions: [
          TextButton(
            child: const Text("Vazgeç"),
            onPressed: () => Navigator.of(ctx).pop(),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text("İptali Onayla"),
            onPressed: () async {
              if (formKey.currentState!.validate()) {
                final reason = reasonController.text.trim();
                try {
                  await _firestoreService.cancelOrder(widget.order.id, reason);
                  if (!mounted) return;
                  Navigator.of(ctx).pop();
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text("Sipariş iptal edildi ve arşive taşındı."),
                        backgroundColor: Colors.green),
                  );
                } catch (e) {
                  if (!mounted) return;
                  Navigator.of(ctx).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text("Hata: ${e.toString()}"),
                        backgroundColor: Colors.red),
                  );
                }
              }
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final finalProduct = widget.order.finalProduct;
    final bool isActionable = widget.order.status != 'tamamlandi';

    Widget content = SingleChildScrollView(
      padding: const EdgeInsets.all(12.0),
      child: Column(
        children: [
          _buildInfoCard(
            title: "Müşteri Bilgileri",
            icon: Icons.person_outline,
            child: ListTile(
              title: Text(widget.order.customerName,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 16)),
              subtitle: Row(
                children: [
                  Text("Sipariş ID: ${widget.order.id.substring(0, 8)}..."),
                  const SizedBox(width: 8),
                  InkWell(
                    borderRadius: BorderRadius.circular(20),
                    onTap: () {
                      Clipboard.setData(ClipboardData(text: widget.order.id));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Sipariş ID panoya kopyalandı!"),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    },
                    child: const Padding(
                      padding: EdgeInsets.all(4.0),
                      child: Icon(Icons.copy, size: 16, color: Colors.grey),
                    ),
                  ),
                ],
              ),
            ),
          ),
          _buildInfoCard(
            title: "Ürün Bilgileri",
            icon: Icons.inventory_2_outlined,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(finalProduct.productName,
                      style: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold)),
                  const Divider(height: 24),
                  const Text("Notlar:",
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(finalProduct.notes.isNotEmpty
                      ? finalProduct.notes
                      : "Ek not bulunmuyor."),
                  const SizedBox(height: 12),
                  Text("Kalite: ${finalProduct.quality}",
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ),
          _buildInfoCard(
            title: "Kullanılan Malzemeler (Reçete)",
            icon: Icons.construction_outlined,
            child: Column(
              children: widget.order.requiredComponents
                  .map((component) => ListTile(
                dense: true,
                title: Text(component.itemName),
                trailing: Text("${component.quantityUsed} adet"),
              ))
                  .toList(),
            ),
          ),
          if (isActionable)
            _buildInfoCard(
              title: "Durumu Güncelle",
              icon: Icons.published_with_changes_outlined,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: DropdownButtonFormField<String>(
                  value: _selectedStatus,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8)),
                    contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                  items: _statusOptions.map((String status) {
                    return DropdownMenuItem<String>(
                        value: status, child: Text(_formatStatusString(status)));
                  }).toList(),
                  onChanged: (String? newValue) {
                    if (newValue != null && newValue != _selectedStatus) {
                      _updateStatus(newValue);
                    }
                  },
                ),
              ),
            ),
          const SizedBox(height: 16),
          if (widget.order.status == 'kargoya_hazir')
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  icon: const Icon(Icons.check_circle_outline),
                  label: const Text("Siparişi Bitir"),
                  onPressed: () async {
                    try {
                      await _firestoreService.finishOrder(widget.order.id);
                      if (!mounted) return;
                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Sipariş başarıyla tamamlandı."),
                          backgroundColor: Colors.teal,
                        ),
                      );
                    } catch (e) {
                      if (!mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                              "Hata: Sipariş bitirilemedi. ${e.toString()}"),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  },
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.teal,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ),
          if (isActionable)
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                icon: const Icon(Icons.cancel_outlined),
                label: const Text("Siparişi İptal Et"),
                onPressed: _showCancelDialog,
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red,
                  side: const BorderSide(color: Colors.red),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
        ],
      ),
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
      appBar: AppBar(
        title: const Text("Sipariş Detayları"),
        elevation: 1,
      ),
      body: content,
    );
  }

  Widget _buildInfoCard(
      {required String title, required IconData icon, required Widget child}) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12.0),
      elevation: 2,
      shadowColor: Colors.black.withOpacity(0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Row(
              children: [
                Icon(icon, color: Colors.grey.shade700),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          child,
        ],
      ),
    );
  }
}