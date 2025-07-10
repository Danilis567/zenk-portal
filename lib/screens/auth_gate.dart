// lib/screens/auth_gate.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:zenk_app/models/user_model.dart';
import 'package:zenk_app/screens/dashboard_screen.dart';
import 'package:zenk_app/screens/login_screen.dart';
import 'package:zenk_app/services/firestore_service.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const LoginScreen();
        }
        return FutureBuilder<UserModel?>(
          future: FirestoreService().getUserData(snapshot.data!.uid),
          builder: (context, userSnapshot) {
            if (userSnapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                  body: Center(child: CircularProgressIndicator()));
            }
            if (userSnapshot.hasError || !userSnapshot.hasData) {
              return const Scaffold(
                  body: Center(child: Text("Kullanıcı verisi alınamadı.")));
            }
            final userRole = userSnapshot.data!.role;
            return DashboardScreen(userRole: userRole);
          },
        );
      },
    );
  }
}