// lib/screens/stock_edit_screen.dart
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:zenk_app/models/stock_item_model.dart';
import 'package:zenk_app/services/firestore_service.dart';

class StockEditScreen extends StatefulWidget {
  final StockItemModel stockItem;
  const StockEditScreen({super.key, required this.stockItem});

  @override
  State<StockEditScreen> createState() => _StockEditScreenState();
}

class _StockEditScreenState extends State<StockEditScreen> {
  late TextEditingController _quantityController;
  final FirestoreService _firestoreService = FirestoreService();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _quantityController =
        TextEditingController(text: widget.stockItem.quantity.toString());
  }

  @override
  void dispose() {
    _quantityController.dispose();
    super.dispose();
  }

  Future<void> _saveQuantity() async {
    if (_isLoading) return;

    final newQuantity = int.tryParse(_quantityController.text);
    if (newQuantity == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("Lütfen geçerli bir sayı girin."),
            backgroundColor: Colors.red),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await _firestoreService.updateStockQuantity(
          widget.stockItem.id, newQuantity);
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text("Stok başarıyla güncellendi."),
              backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text("Hata: Stok güncellenemedi."),
              backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _adjustQuantity(int amount) {
    int currentQuantity = int.tryParse(_quantityController.text) ?? 0;
    currentQuantity += amount;
    _quantityController.text = currentQuantity.toString();
  }

  @override
  Widget build(BuildContext context) {
    Widget content = SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Center(
              child: SizedBox(
                height: 200,
                width: 200,
                child: Hero(
                  tag: 'stock_image_${widget.stockItem.id}',
                  child: Card(
                    clipBehavior: Clip.antiAlias,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    elevation: 4,
                    child: Image.network(widget.stockItem.imageUrl,
                        fit: BoxFit.cover),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              widget.stockItem.itemName,
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            const Text("Mevcut Stoğu Düzenle",
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600)),
            const SizedBox(height: 16),
            Container(
              padding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildQuantityButton(
                      icon: Icons.remove,
                      color: Colors.redAccent,
                      onPressed: () => _adjustQuantity(-1)),
                  Expanded(
                    child: TextFormField(
                      controller: _quantityController,
                      textAlign: TextAlign.center,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      style: const TextStyle(
                          fontSize: 28, fontWeight: FontWeight.bold),
                      decoration:
                      const InputDecoration(border: InputBorder.none),
                    ),
                  ),
                  _buildQuantityButton(
                      icon: Icons.add,
                      color: Colors.green,
                      onPressed: () => _adjustQuantity(1)),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Text("Hızlı Ekle",
                style: TextStyle(fontSize: 16, color: Colors.grey)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 12.0,
              alignment: WrapAlignment.center,
              children: [
                _buildQuickAddButton(10),
                _buildQuickAddButton(100),
                _buildQuickAddButton(1000),
              ],
            ),
            const SizedBox(height: 40),
            ElevatedButton.icon(
              onPressed: _isLoading ? null : _saveQuantity,
              icon: _isLoading ? Container() : const Icon(Icons.save),
              label: _isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text("Değişiklikleri Kaydet"),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 55),
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
                textStyle: const TextStyle(
                    fontSize: 18, fontWeight: FontWeight.bold),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
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
        title: Text(widget.stockItem.itemName),
        elevation: 1,
      ),
      body: content,
    );
  }

  Widget _buildQuickAddButton(int amount) {
    return OutlinedButton(
      onPressed: () => _adjustQuantity(amount),
      style: OutlinedButton.styleFrom(
        foregroundColor: Colors.orange.shade900,
        side: BorderSide(color: Colors.orange.shade200),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16),
      ),
      child: Text(
        "+$amount",
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildQuantityButton(
      {required IconData icon,
        required Color color,
        required VoidCallback onPressed}) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        shape: const CircleBorder(),
        padding: const EdgeInsets.all(16),
        backgroundColor: color.withOpacity(0.1),
        foregroundColor: color,
        elevation: 0,
      ),
      child: Icon(icon),
    );
  }
}