// lib/screens/add_stock_item_screen.dart
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:zenk_app/services/firestore_service.dart';
import 'package:zenk_app/services/storage_service.dart';

class AddStockItemScreen extends StatefulWidget {
  const AddStockItemScreen({super.key});

  @override
  State<AddStockItemScreen> createState() => _AddStockItemScreenState();
}

class _AddStockItemScreenState extends State<AddStockItemScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firestoreService = FirestoreService();
  final _storageService = StorageService();

  final _itemNameController = TextEditingController();
  final _quantityController = TextEditingController();

  XFile? _selectedImage;
  bool _isLoading = false;

  @override
  void dispose() {
    _itemNameController.dispose();
    _quantityController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        _selectedImage = image;
      });
    }
  }

  Future<void> _saveStockItem() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("Lütfen bir resim seçin."),
          backgroundColor: Colors.red));
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      String imageUrl = await _storageService.uploadImage(_selectedImage!);

      await _firestoreService.addStockItem(
        itemName: _itemNameController.text,
        initialQuantity: int.parse(_quantityController.text),
        imageUrl: imageUrl,
      );

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text("Stok ürünü başarıyla eklendi."),
            backgroundColor: Colors.green));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text("Hata: Ürün eklenemedi."),
            backgroundColor: Colors.red));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
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
            InkWell(
              onTap: _pickImage,
              child: Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade400, width: 1),
                ),
                child: _selectedImage == null
                    ? const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add_a_photo_outlined,
                        size: 50, color: Colors.grey),
                    SizedBox(height: 8),
                    Text("Resim Seçmek İçin Tıkla"),
                  ],
                )
                    : ClipRRect(
                  borderRadius: BorderRadius.circular(11),
                  child: kIsWeb
                      ? Image.network(_selectedImage!.path,
                      fit: BoxFit.cover)
                      : Image.file(File(_selectedImage!.path),
                      fit: BoxFit.cover),
                ),
              ),
            ),
            const SizedBox(height: 24),
            TextFormField(
              controller: _itemNameController,
              decoration: const InputDecoration(
                  labelText: "Ürün Adı", border: OutlineInputBorder()),
              validator: (value) =>
              value == null || value.isEmpty ? "Lütfen ürün adı girin." : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _quantityController,
              decoration: const InputDecoration(
                  labelText: "Başlangıç Stoğu (Adet)",
                  border: OutlineInputBorder()),
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              validator: (value) =>
              value == null || value.isEmpty ? "Lütfen adet girin." : null,
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _isLoading ? null : _saveStockItem,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                backgroundColor: Colors.blueAccent,
                foregroundColor: Colors.white,
              ),
              child: _isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text("Stok Ürününü Kaydet"),
            ),
          ],
        ),
      ),
    );

    return Scaffold(
      appBar: AppBar(title: const Text("Yeni Stok Ürünü Ekle")),
      body: kIsWeb
          ? Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600), // Formlar için daha dar bir genişlik
          child: formContent,
        ),
      )
          : formContent,
    );
  }
}