// lib/screens/add_order_screen.dart
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:zenk_app/models/stock_item_model.dart';
import 'package:zenk_app/services/firestore_service.dart';

class RecipeItem {
  final StockItemModel stockItem;
  late final TextEditingController controller;
  RecipeItem({required this.stockItem, int perUnitQuantity = 1}) {
    controller = TextEditingController(text: perUnitQuantity.toString());
  }
  void dispose() {
    controller.dispose();
  }
}

class AddOrderScreen extends StatefulWidget {
  const AddOrderScreen({super.key});
  @override
  State<AddOrderScreen> createState() => _AddOrderScreenState();
}

class _AddOrderScreenState extends State<AddOrderScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firestoreService = FirestoreService();
  final _customerNameController = TextEditingController();
  final _finalProductQuantityController = TextEditingController();
  final _finalProductNameController = TextEditingController();
  final _finalProductNotesController = TextEditingController();
  final _finalProductQualityController = TextEditingController();
  final List<RecipeItem> _selectedComponents = [];
  bool _isLoading = false;

  @override
  void dispose() {
    _customerNameController.dispose();
    _finalProductQuantityController.dispose();
    _finalProductNameController.dispose();
    _finalProductNotesController.dispose();
    _finalProductQualityController.dispose();
    for (var item in _selectedComponents) {
      item.dispose();
    }
    super.dispose();
  }

  Future<void> _saveOrder() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedComponents.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Lütfen en az bir malzeme ekleyin."), backgroundColor: Colors.red));
      return;
    }
    setState(() { _isLoading = true; });

    try {
      final int finalProductQuantity = int.parse(_finalProductQuantityController.text);
      final Map<String, dynamic> newOrderData = {
        'customerName': _customerNameController.text.trim(),
        'status': 'imalatta',
        'finalProduct': {
          'productName': _finalProductNameController.text.trim(),
          'notes': _finalProductNotesController.text.trim(),
          'quality': int.tryParse(_finalProductQualityController.text.trim()) ?? 0,
        },
        'requiredComponents': _selectedComponents.map((item) {
          final perUnitQty = int.tryParse(item.controller.text) ?? 1;
          return {'itemId': item.stockItem.id, 'itemName': item.stockItem.itemName, 'quantityUsed': perUnitQty * finalProductQuantity};
        }).toList(),
      };

      await _firestoreService.createOrderAndUpdateStock(newOrderData);

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Sipariş başarıyla oluşturuldu."), backgroundColor: Colors.green));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Hata: ${e.toString()}"), backgroundColor: Colors.red));
      }
    } finally {
      if (mounted) {
        setState(() { _isLoading = false; });
      }
    }
  }

  void _showComponentSelectionSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            String searchQuery = "";
            return DraggableScrollableSheet(
              expand: false,
              initialChildSize: 0.8,
              maxChildSize: 0.9,
              builder: (_, controller) {
                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                      child: Column(
                        children: [
                          Text("Malzeme Seç", style: Theme.of(context).textTheme.titleLarge),
                          const SizedBox(height: 12),
                          TextField(
                            onChanged: (value) {
                              setModalState(() {
                                searchQuery = value.toLowerCase();
                              });
                            },
                            decoration: const InputDecoration(
                              labelText: "Malzeme Ara",
                              prefixIcon: Icon(Icons.search),
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: StreamBuilder<List<StockItemModel>>(
                        stream: _firestoreService.getStockItemsStream(),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                          final filteredItems = snapshot.data!.where((item) {
                            return item.itemName.toLowerCase().contains(searchQuery);
                          }).toList();
                          if (filteredItems.isEmpty) return const Center(child: Text("Sonuç bulunamadı."));
                          return ListView.builder(
                            controller: controller,
                            itemCount: filteredItems.length,
                            itemBuilder: (context, index) {
                              final item = filteredItems[index];
                              final isAlreadyAdded = _selectedComponents.any((comp) => comp.stockItem.id == item.id);
                              return ListTile(
                                leading: CircleAvatar(
                                  backgroundImage: NetworkImage(item.imageUrl),
                                  onBackgroundImageError: (e, s) {},
                                ),
                                title: Text(item.itemName),
                                subtitle: Text("Stok: ${item.quantity}"),
                                enabled: !isAlreadyAdded,
                                trailing: isAlreadyAdded ? const Icon(Icons.check, color: Colors.green) : null,
                                onTap: isAlreadyAdded ? null : () {
                                  setState(() {
                                    _selectedComponents.add(RecipeItem(stockItem: item));
                                  });
                                  Navigator.pop(context);
                                },
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ],
                );
              },
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget formContent = Form(
      key: _formKey,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              controller: _customerNameController,
              decoration: const InputDecoration(labelText: "Müşteri Adı", border: OutlineInputBorder()),
              validator: (value) => value == null || value.isEmpty ? "Bu alan boş olamaz" : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _finalProductNameController,
              decoration: const InputDecoration(labelText: "Üretilecek Ürün Adı (Başlık)", border: OutlineInputBorder()),
              validator: (value) => value == null || value.isEmpty ? "Bu alan boş olamaz" : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _finalProductNotesController,
              decoration: const InputDecoration(labelText: "Üretim Notları", border: OutlineInputBorder()),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _finalProductQualityController,
              decoration: const InputDecoration(labelText: "Ürün Kalitesi (Sayısal)", border: OutlineInputBorder()),
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              validator: (value) {
                if (value == null || value.isEmpty) return "Bu alan boş olamaz";
                if (int.tryParse(value) == null) return "Geçerli bir sayı girin.";
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _finalProductQuantityController,
              decoration: const InputDecoration(labelText: "Sipariş Adedi (Üretilecek Miktar)", border: OutlineInputBorder()),
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              validator: (value) => value == null || value.isEmpty ? "Bu alan boş olamaz" : null,
            ),
            const SizedBox(height: 24),
            const Text("Kullanılacak Malzemeler (Reçete)", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const Divider(),
            if (_selectedComponents.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 24.0),
                child: Center(child: Text("Henüz malzeme eklenmedi.", style: TextStyle(color: Colors.grey))),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _selectedComponents.length,
                itemBuilder: (context, index) {
                  final component = _selectedComponents[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        children: [
                          Expanded(child: Text(component.stockItem.itemName, style: const TextStyle(fontWeight: FontWeight.bold))),
                          const Text("Ürün Başı Adet:"),
                          SizedBox(
                            width: 60,
                            child: TextFormField(
                              controller: component.controller,
                              textAlign: TextAlign.center,
                              keyboardType: TextInputType.number,
                              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                              decoration: const InputDecoration(border: UnderlineInputBorder()),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline, color: Colors.red),
                            onPressed: () {
                              setState(() {
                                _selectedComponents[index].dispose();
                                _selectedComponents.removeAt(index);
                              });
                            },
                          )
                        ],
                      ),
                    ),
                  );
                },
              ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              icon: const Icon(Icons.add),
              label: const Text("Malzeme Ekle"),
              onPressed: _showComponentSelectionSheet,
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _isLoading ? null : _saveOrder,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
              ),
              child: _isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text("Siparişi Kaydet"),
            ),
          ],
        ),
      ),
    );

    return Scaffold(
      appBar: AppBar(title: const Text("Yeni Sipariş Oluştur")),
      body: kIsWeb
          ? Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Card(
            margin: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 24.0),
            elevation: 4,
            child: formContent,
          ),
        ),
      )
          : formContent,
    );
  }
}