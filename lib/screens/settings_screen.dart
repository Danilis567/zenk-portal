// lib/screens/settings_screen.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:zenk_app/models/user_model.dart';
import 'package:zenk_app/providers/theme_provider.dart';
import 'package:zenk_app/screens/bug_report_screen.dart';
import 'package:zenk_app/services/auth_service.dart';
import 'package:zenk_app/services/firestore_service.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text("Çıkış Yap"),
          content: const Text("Oturumu sonlandırmak istediğinizden emin misiniz?"),
          actions: <Widget>[
            TextButton(
              child: const Text("İptal"),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
            FilledButton(
              child: const Text("Çıkış Yap"),
              style: FilledButton.styleFrom(backgroundColor: Colors.redAccent),
              onPressed: () async {
                Navigator.of(dialogContext).pop();
                await AuthService().signOut();
              },
            ),
          ],
        );
      },
    );
  }

  void _showAppInfo(BuildContext context) async {
    final packageInfo = await PackageInfo.fromPlatform();
    showAboutDialog(
      context: context,
      applicationName: "Zenk Portal",
      applicationVersion: packageInfo.version,
      applicationLegalese: '© 2025 Zenk Metal',

      children: [
        const Padding(
          padding: EdgeInsets.only(top: 15),
          child: Text("Bu uygulama, üretim ve stok takibi için geliştirilmiştir."),
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final firestoreService = FirestoreService();
    final firebaseUser = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(title: const Text("Ayarlar")),
      body: ListView(
        padding: const EdgeInsets.all(12.0),
        children: [
          if (firebaseUser != null)
            FutureBuilder<UserModel?>(
              future: firestoreService.getUserData(firebaseUser.uid),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData) {
                  return const ListTile(
                      title: Text("Profil bilgileri yüklenemedi."));
                }

                final user = snapshot.data!;
                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context)
                        .colorScheme
                        .primaryContainer
                        .withOpacity(0.4),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        foregroundColor:
                        Theme.of(context).colorScheme.onPrimary,
                        // DEĞİŞİKLİK BURADA: Artık e-postanın ilk harfini alıyor
                        child: Text(user.email.isNotEmpty ? user.email[0].toUpperCase() : 'U'),
                      ),
                      const SizedBox(height: 12),
                      Text(user.displayName,
                          style: const TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text(user.role.toUpperCase(),
                          style: TextStyle(
                              fontSize: 14,
                              color: Theme.of(context).colorScheme.secondary,
                              letterSpacing: 1.2)),
                    ],
                  ),
                );
              },
            ),
          const SizedBox(height: 20),
          Card(
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: [
                Consumer<ThemeProvider>(
                  builder: (context, themeProvider, child) {
                    return SwitchListTile(
                      title: const Text("Karanlık Mod"),
                      value: themeProvider.themeMode == ThemeMode.dark,
                      onChanged: (value) => themeProvider.toggleTheme(value),
                      secondary: const Icon(Icons.dark_mode_outlined),
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Card(
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.bug_report_outlined),
                  title: const Text("Hata veya Öneri Bildir"),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const BugReportScreen()),
                    );
                  },
                ),
                const Divider(height: 1, indent: 16, endIndent: 16),
                ListTile(
                  leading: const Icon(Icons.info_outline),
                  title: const Text("Uygulama Hakkında"),
                  onTap: () => _showAppInfo(context),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Card(
            clipBehavior: Clip.antiAlias,
            child: ListTile(
              leading: const Icon(Icons.logout, color: Colors.redAccent),
              title: const Text("Çıkış Yap",
                  style: TextStyle(
                      color: Colors.redAccent, fontWeight: FontWeight.w600)),
              onTap: () => _showLogoutDialog(context),
            ),
          ),
        ],
      ),
    );
  }
}