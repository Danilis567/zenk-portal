import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:zenk_app/models/user_model.dart';
import 'package:zenk_app/services/firestore_service.dart';
import 'package:zenk_app/widgets/order_list.dart';

class OrdersScreen extends StatefulWidget {
  final String userRole;
  const OrdersScreen({super.key, required this.userRole});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  String _searchQuery = '';
  Timer? _debounce;
  UserModel? _currentUser;
  bool _isUserLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    final firebaseUser = FirebaseAuth.instance.currentUser;
    if (firebaseUser != null) {
      final userModel = await FirestoreService().getUserData(firebaseUser.uid);
      if (mounted) {
        setState(() {
          _currentUser = userModel;
          _isUserLoading = false;
        });
      }
    } else {
      if (mounted) {
        setState(() { _isUserLoading = false; });
      }
    }
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() {
          _searchQuery = query;
        });
      }
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _isUserLoading
                    ? const Text("Yükleniyor...", style: TextStyle(fontSize: 14))
                    : Text(
                  "Merhaba, ${_currentUser?.email ?? 'Kullanıcı'}!",
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 16),
                TextField(
                  onChanged: _onSearchChanged,
                  decoration: InputDecoration(
                    hintText: "Müşteri adına göre ara...",
                    prefixIcon: const Icon(Icons.search),
                    filled: true,
                    fillColor: isDarkMode ? Colors.grey[850] : Colors.white,
                    contentPadding: EdgeInsets.zero,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: isDarkMode ? Colors.grey.shade800 : Colors.grey.shade200,
              borderRadius: BorderRadius.circular(30),
            ),
            child: TabBar(
              labelColor: isDarkMode ? Colors.black : Colors.white,
              unselectedLabelColor: isDarkMode ? Colors.white70 : Colors.black54,
              indicatorSize: TabBarIndicatorSize.tab,
              dividerColor: Colors.transparent,
              indicator: BoxDecoration(
                color: Colors.orange,
                borderRadius: BorderRadius.circular(30),
              ),
              tabs: const [
                Tab(child: Text("Aktif Siparişler", style: TextStyle(fontWeight: FontWeight.bold))),
                Tab(child: Text("Teslime Hazır", style: TextStyle(fontWeight: FontWeight.bold))),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              children: [
                OrderList(statuses: const ['imalatta', 'polisajda', 'montajda'], searchQuery: _searchQuery),
                OrderList(statuses: const ['kargoya_hazir'], searchQuery: _searchQuery),
              ],
            ),
          ),
        ],
      ),
    );
  }
}