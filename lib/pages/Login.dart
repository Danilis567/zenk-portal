import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:zenk_portal/localize.dart';
import 'package:zenk_portal/style/styled.dart';
import 'package:zenk_portal/pages/reset_password.dart'; // ResetPassword sayfasını ekleyin
import 'package:email_validator/email_validator.dart'; // email_validator paketini kullanarak doğrulama

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscureText = true; // Track password visibility

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _togglePasswordVisibility() {
    setState(() {
      _obscureText = !_obscureText; // Toggle visibility
    });
  }

  void _navigateToResetPassword() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const Resetpassword()),
    );
  }

  void _login() {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty) {
      _showSnackBar("Lütfen e-posta adresinizi girin.");
    } else if (!EmailValidator.validate(email)) {
      _showSnackBar("Lütfen geçerli bir e-posta adresi girin.");
    } else if (password.isEmpty) {
      _showSnackBar("Lütfen şifrenizi girin.");
    } else {
      // E-posta ve şifre doğrulama başarılı, giriş işlemlerini burada yapabilirsiniz
      _showSnackBar("Giriş başarılı!"); // Bu sadece bir örnek, gerçek uygulamanızda giriş işlemleri yapılmalıdır.
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            "assets/img1.png",
            fit: BoxFit.cover, // Cover the entire screen
          ),
          Center(
            child: Container(
              width: 380,
              padding: const EdgeInsets.all(16.0), // Padding around the form
              margin: const EdgeInsets.symmetric(horizontal: 20.0), // Margin for spacing
              decoration: BoxDecoration(
                color: Colors.white, // White background for the form container
                borderRadius: BorderRadius.circular(12), // Rounded corners
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    spreadRadius: 4,
                    blurRadius: 12,
                    offset: const Offset(0, 2), // Shadow position
                  ),
                ],
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center, // Dikey ortalamak için
                  crossAxisAlignment: CrossAxisAlignment.stretch, // Genişlik boyunca yayılmak için
                  children: [
                    Image.asset(
                      "assets/logo.png",
                      width: 85,
                      height: 85,
                    ),
                    const SizedBox(height: 25),
                    Text(
                      LocalText().hello,
                      style: CustomTextStyle.titleTextStyle,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    TextField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: Colors.orange), // Kenar rengi turuncu
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.orange.shade200), // Kenar rengi turuncu
                          borderRadius: BorderRadius.circular(10),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.orange), // Kenar rengi turuncu
                          borderRadius: BorderRadius.circular(10),
                        ),
                        hintText: 'Email',
                        hintStyle: TextStyle(color: Colors.grey), // Placeholder rengi gri
                        prefixIcon: Icon(Icons.email, color: Colors.orange), // İkon ekleyin
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _passwordController,
                      obscureText: _obscureText, // Toggle password visibility
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: Colors.orange), // Kenar rengi turuncu
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.orange.shade200), // Kenar rengi turuncu
                          borderRadius: BorderRadius.circular(10),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.orange), // Kenar rengi turuncu
                          borderRadius: BorderRadius.circular(10),
                        ),
                        hintText: 'Şifre',
                        hintStyle: TextStyle(color: Colors.grey), // Placeholder rengi gri
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscureText ? Icons.visibility_off : Icons.visibility,
                            color: Colors.orange, // Suffix ikon rengi turuncu
                          ),
                          onPressed: _togglePasswordVisibility,
                        ),
                        prefixIcon: Icon(
                          CupertinoIcons.padlock_solid,
                          color: Colors.orange,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Align(
                      alignment: Alignment.centerLeft, // Align text to the start
                      child: GestureDetector(
                        onTap: _navigateToResetPassword, // Navigate to reset password page
                        child: const Text(
                          "Şifremi unuttum",
                          textAlign: TextAlign.start,
                          style: TextStyle(
                            color: Colors.orange, // Metin rengi turuncu
                            fontWeight: FontWeight.bold, // Metni kalın yap
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: _login, // Giriş işlemini tetikler
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: Colors.orange, // Buton arka plan rengi turuncu
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8), // Kenar yuvarlama
                        ),
                      ),
                      child: Center(child: Text(LocalText().LoginPageButtonText)),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}