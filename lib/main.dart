import 'package:flutter/material.dart';
import 'package:zenk_portal/pages/Home.dart';
import 'package:zenk_portal/pages/Login.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        useMaterial3: true,
        primaryColor: Colors.orange, // Ana vurgu rengini turuncu yapıyoruz
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.orange,
          primary: Colors.orange, // Ana renk olarak turuncu kullanıyoruz
          secondary: Colors.amber, // İkinci rengimizi ayarlıyoruz, isteğe bağlı
        ),


      ),
      debugShowCheckedModeBanner: false,
      home: Scaffold(body: SafeArea(child: Home())),
    );
  }
}
