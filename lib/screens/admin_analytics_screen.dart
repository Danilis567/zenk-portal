// lib/screens/admin_analytics_screen.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:zenk_app/services/auth_service.dart';
import 'package:zenk_app/services/firestore_service.dart';

enum AnalyticsView { daily, weekly }

class AdminAnalyticsScreen extends StatefulWidget {
  const AdminAnalyticsScreen({super.key});

  @override
  State<AdminAnalyticsScreen> createState() => _AdminAnalyticsScreenState();
}

class _AdminAnalyticsScreenState extends State<AdminAnalyticsScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  final AuthService _authService = AuthService();

  late Future<Map<String, dynamic>> _analyticsData;
  DateTime _selectedDate = DateTime.now();
  AnalyticsView _currentView = AnalyticsView.daily;

  @override
  void initState() {
    super.initState();
    _loadDataForSelection();
  }

  void _loadDataForSelection() {
    final range = _getDateRangeForSelection();
    setState(() {
      _analyticsData = _fetchAnalyticsData(range['start']!, range['end']!);
    });
  }

  Map<String, DateTime> _getDateRangeForSelection() {
    if (_currentView == AnalyticsView.daily) {
      final start = DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day);
      final end = start.add(const Duration(days: 1));
      return {'start': start, 'end': end};
    } else { // Weekly
      final dayOfWeek = _selectedDate.weekday; // Pazartesi = 1, Pazar = 7
      final start = DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day - (dayOfWeek - 1));
      final end = start.add(const Duration(days: 7));
      return {'start': start, 'end': end};
    }
  }

  Future<Map<String, dynamic>> _fetchAnalyticsData(DateTime startDate, DateTime endDate) async {
    final results = await Future.wait([
      _firestoreService.getAnalyticsForDateRange(startDate: startDate, endDate: endDate),
      _authService.getLoginLogsForDateRange(startDate: startDate, endDate: endDate),
    ]);
    return {
      'stats': results[0],
      'loginLogs': results[1],
    };
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2022),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      locale: const Locale('tr', 'TR'),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
      _loadDataForSelection();
    }
  }

  String _getAppBarTitle() {
    final f = DateFormat.yMMMMd('tr_TR');
    if (_currentView == AnalyticsView.daily) {
      return f.format(_selectedDate);
    } else {
      final range = _getDateRangeForSelection();
      // Tarih formatı düzeltildi
      final String startFormatted = DateFormat.Md('tr_TR').format(range['start']!);
      final String endFormatted = f.format(range['end']!.subtract(const Duration(days: 1)));
      return '$startFormatted - $endFormatted';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(_getAppBarTitle()),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today),
            tooltip: 'Tarih Seç',
            onPressed: () => _selectDate(context),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: SegmentedButton<AnalyticsView>(
              segments: const <ButtonSegment<AnalyticsView>>[
                ButtonSegment<AnalyticsView>(value: AnalyticsView.daily, label: Text('Günlük')),
                ButtonSegment<AnalyticsView>(value: AnalyticsView.weekly, label: Text('Haftalık')),
              ],
              selected: {_currentView},
              onSelectionChanged: (Set<AnalyticsView> newSelection) {
                setState(() {
                  _currentView = newSelection.first;
                });
                _loadDataForSelection();
              },
            ),
          ),
          Expanded(
            child: FutureBuilder<Map<String, dynamic>>(
              future: _analyticsData,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text('Bir hata oluştu:\n${snapshot.error}', textAlign: TextAlign.center),
                  ));
                }
                if (!snapshot.hasData || snapshot.data == null) {
                  return const Center(child: Text('Veri bulunamadı.'));
                }

                final stats = snapshot.data!['stats'] as Map<String, dynamic>;
                final stockUsage = stats['stockUsage'] as Map<String, int>;
                final loginLogs = snapshot.data!['loginLogs'] as List<QueryDocumentSnapshot>;

                return RefreshIndicator(
                  onRefresh: () async => _loadDataForSelection(),
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildOrderStatsCard(stats),
                        const SizedBox(height: 20),
                        _buildStockUsageCard(stockUsage),
                        const SizedBox(height: 20),
                        _buildLoginLogsCard(loginLogs),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderStatsCard(Map<String, dynamic> stats) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildStatItem('Yeni', stats['newOrders'] ?? 0, Colors.orange),
            _buildStatItem('Biten', stats['completedOrders'] ?? 0, Colors.green),
            _buildStatItem('İptal', stats['cancelledOrders'] ?? 0, Colors.red),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, int count, Color color) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        Text(
          count.toString(),
          style: Theme.of(context)
              .textTheme
              .displaySmall
              ?.copyWith(color: color, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildStockUsageCard(Map<String, int> stockUsage) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDarkMode ? Colors.white70 : Colors.black54;

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Stok Kullanımı', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 24),
            if (stockUsage.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 60.0),
                child: Center(child: Text('Seçili aralıkta stok kullanımı olmadı.')),
              )
            else
              SizedBox(
                height: 220,
                child: BarChart(
                  BarChartData(
                    maxY: (stockUsage.values.isNotEmpty
                        ? stockUsage.values.reduce((a, b) => a > b ? a : b)
                        : 10) * 1.2,
                    alignment: BarChartAlignment.spaceAround,
                    barTouchData: BarTouchData(
                      touchTooltipData: BarTouchTooltipData(
                        getTooltipColor: (BarChartGroupData group) => Colors.blueGrey,
                        tooltipPadding: const EdgeInsets.all(8),
                        tooltipMargin: 8,
                        getTooltipItem: (group, groupIndex, rod, rodIndex) {
                          final itemName = stockUsage.keys.elementAt(group.x.toInt());
                          return BarTooltipItem(
                            '$itemName\n',
                            const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                            children: <TextSpan>[
                              TextSpan(
                                text: rod.toY.round().toString(),
                                style: const TextStyle(color: Colors.yellow, fontWeight: FontWeight.bold),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                    titlesData: FlTitlesData(
                      show: true,
                      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 42,
                          getTitlesWidget: (double value, TitleMeta meta) {
                            final index = value.toInt();
                            final keys = stockUsage.keys.toList();
                            if (index < 0 || index >= keys.length) {
                              return const SizedBox.shrink();
                            }
                            return SideTitleWidget(
                              meta: meta,
                              space: 4,
                              child: Text(
                                keys[index],
                                style: TextStyle(
                                  color: textColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 10,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.center,
                              ),
                            );
                          },
                        ),
                      ),
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 32,
                          getTitlesWidget: (double value, TitleMeta meta) {
                            if (value == 0 || value == meta.max) {
                              return const SizedBox.shrink();
                            }
                            return Text(
                              value.toInt().toString(),
                              style: TextStyle(color: textColor, fontSize: 10),
                              textAlign: TextAlign.left,
                            );
                          },
                        ),
                      ),
                    ),
                    borderData: FlBorderData(show: false),
                    gridData: const FlGridData(show: false),
                    barGroups: List.generate(stockUsage.length, (index) {
                      return BarChartGroupData(
                        x: index,
                        barRods: [
                          BarChartRodData(
                            toY: stockUsage.values.elementAt(index).toDouble(),
                            color: Colors.blueAccent,
                            width: 16,
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                          )
                        ],
                      );
                    }),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoginLogsCard(List<QueryDocumentSnapshot> logs) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text('Giriş Hareketleri', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 10),
            if (logs.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 20.0),
                child: Center(child: Text('Seçili aralıkta giriş yapan olmadı.')),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: logs.length,
                itemBuilder: (context, index) {
                  final log = logs[index].data() as Map<String, dynamic>;
                  final timestamp = (log['timestamp'] as Timestamp?)?.toDate();
                  return ListTile(
                    leading: const Icon(Icons.person, color: Colors.grey),
                    title: Text(log['email'] ?? 'Email yok'),
                    trailing: Text(timestamp != null
                        ? DateFormat.yMd('tr').add_Hm().format(timestamp)
                        : 'Saat yok'),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}