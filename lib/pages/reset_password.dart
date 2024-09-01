import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:zenk_portal/style/styled.dart';
import 'package:email_validator/email_validator.dart'; // email_validator paketini kullanarak doğrulama

class Resetpassword extends StatefulWidget {
  const Resetpassword({super.key});

  @override
  State<Resetpassword> createState() => _ResetpasswordState();
}

class _ResetpasswordState extends State<Resetpassword> {
  final TextEditingController _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _resetPassword() {
    final email = _emailController.text.trim();

    if (email.isEmpty) {
      // E-posta adresi boş
      _showSnackBar("Lütfen e-posta adresinizi girin.");
    } else if (EmailValidator.validate(email)) {
      // E-posta adresi geçerli
      _showSnackBar("Şifre sıfırlama talebiniz e-posta adresinize gönderildi: $email");
    } else {
      // E-posta adresi geçersiz
      _showSnackBar("Lütfen geçerli bir e-posta adresi girin.");
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _goBack() {
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Şifre Sıfırlama"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: _goBack,
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 400), // Maksimum genişlik sınırı
            child: Container(
              padding: const EdgeInsets.all(16.0), // İçerik için padding
              decoration: BoxDecoration(
                color: Colors.orange.shade50, // Arka plan rengini turuncu yap
                borderRadius: BorderRadius.circular(8), // Arka plan kenar yuvarlama radiusu
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch, // Stretch children horizontally
                children: [
                  Container(
                  // İkonun etrafında boşluk
                    decoration: BoxDecoration(
                      color: Colors.white, // İkonun arka plan rengi beyaz
                      shape: BoxShape.circle, // Daire şeklinde arka plan
                    ),
                    child: Icon(
                      CupertinoIcons.lock_circle_fill,
                      size: 100,
                      color: Colors.orange,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Şifrenizi sıfırlamak için e-posta adresinizi girin.',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  TextField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8), // TextField kenar yuvarlama radiusu
                      ),
                      filled: true,
                      fillColor: Colors.white, // TextField arka plan rengi
                      labelText: 'E-posta adresi',
                      prefixIcon: Icon(Icons.email, color: Colors.orange), // İkon rengini turuncu yap
                      labelStyle: TextStyle(color: Colors.orange), // Label rengi turuncu
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.orange, width: 2.0),
                        borderRadius: BorderRadius.circular(8), // Kenar yuvarlama radiusu
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.orange.shade200, width: 1.0),
                        borderRadius: BorderRadius.circular(8), // Kenar yuvarlama radiusu
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity, // Butonun genişliği ekranın tamamını kaplar
                    child: ElevatedButton(
                      onPressed: _resetPassword,
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: Colors.orange, // Buton arka plan rengi
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8), // Kenar yuvarlama radiusu
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: Text("Şifre Sıfırla", style: CustomTextStyle.loginButtonTextStyle),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
