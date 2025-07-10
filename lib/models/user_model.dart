// lib/models/user_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String displayName;
  final String role;
  final String email;

  UserModel({
    required this.uid,
    required this.displayName,
    required this.role,
    required this.email,
  });

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return UserModel(
      uid: doc.id,
      displayName: data['displayName'] ?? 'İsimsiz Kullanıcı',
      role: data['role'] ?? 'rol_yok',
      email: data['email'] ?? '',
    );
  }
}