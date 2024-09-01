import 'package:flutter/material.dart';
import 'package:zenk_portal/localize.dart';
import 'package:zenk_portal/pages/Login.dart';
import 'package:zenk_portal/style/styled.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
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

  @override
  Widget build(BuildContext context) {
    return Login();
  }
}
