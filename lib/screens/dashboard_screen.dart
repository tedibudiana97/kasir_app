import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/transaction_model.dart';
import '../services/database_service.dart';
import '../utils/helpers.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  List<TransactionModel> transactions = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => isLoading = true);
    final data = await DatabaseService.getTransactions();
    setState(() {
      transactions = data;
      isLoading = false;
    });
  }

  int get totalTransactions => transactions.length;
  
  int get totalItems {
    int total = 0;
    for (var item in transactions) {
      total += item.qty;
    }
    return total;
  }
  
  double get totalAmount {
    double total = 0;
    for (var item in transactions) {
      total += item.total;
    }
    return total;
  }

  Map<String, int> get dailyData {
    Map<String, int> data = {};
    for (var item in transactions) {
      final date = item.date.substring(0, 10);
      data[date] = (data[date] ?? 0) + 1;
    }
    return data;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Statistik Card
          Row(
            children: [
              _buildStatCard(
                icon: Icons.receipt,
                title: 'Transaksi',
                value: totalTransactions.toString(),
                color: Colors.blue,
                isDark: isDark,
              ),
              const SizedBox(width: 8),
              _buildStatCard(
                icon: Icons.shopping_cart,
                title: 'Item',
                value: totalItems.toString(),
                color: Colors.green,
                isDark: isDark,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _buildStatCard(
                icon: Icons.money,
                title: 'Pendapatan',
                value: Helpers.formatCurrency(totalAmount),
                color: Colors.orange,
                isDark: isDark,
              ),
              const SizedBox(width: 8),
              _buildStatCard(
                icon: Icons.category,
                title: 'Kategori',
                value: transactions.map((e) => e.category).toSet().length.toString(),
                color: Colors.purple,
                isDark: isDark,
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Grafik Harian
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '📊 Aktivitas Harian',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 150,
                    child: dailyData.isEmpty
                        ? const Center(
                            child: Text('Belum ada data'),
                          )
                        : BarChart(
                            BarChartData(
                              alignment: BarChartAlignment.spaceAround,
                              maxY: dailyData.isEmpty
                                  ? 1
                                  : dailyData.values.reduce((a, b) => a > b ? a : b) * 1.2,
                              barGroups: dailyData.entries.map((entry) {
                                final index = dailyData.keys.toList().indexOf(entry.key);
                                return BarChartGroupData(
                                  x: index,
                                  barRods: [
                                    BarChartRodData(
                                      toY: entry.value.toDouble(),
                                      color: Colors.blue,
                                      width: 20,
                                      borderRadius: const BorderRadius.vertical(
                                          top: Radius.circular(8)),
                                    ),
                                  ],
                                );
                              }).toList(),
                              titlesData: FlTitlesData(
                                bottomTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    getTitlesWidget: (value, meta) {
                                      final index = value.toInt();
                                      final keys = dailyData.keys.toList();
                                      if (index >= 0 && index < keys.length) {
                                        final date = keys[index].substring(8, 10);
                                        return Text(
                                          date,
                                          style: const TextStyle(fontSize: 10),
                                        );
                                      }
                                      return const Text('');
                                    },
                                  ),
                                ),
                                leftTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    reservedSize: 30,
                                    getTitlesWidget: (value, meta) {
                                      return Text(
                                        value.toInt().toString(),
                                        style: const TextStyle(fontSize: 8),
                                      );
                                    },
                                  ),
                                ),
                                topTitles: const AxisTitles(
                                    sideTitles: SideTitles(showTitles: false)),
                                rightTitles: const AxisTitles(
                                    sideTitles: SideTitles(showTitles: false)),
                              ),
                              gridData: FlGridData(
                                show: true,
                                drawVerticalLine: false,
                              ),
                              borderData: FlBorderData(show: false),
                            ),
                          ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // 3 Transaksi Terakhir
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '🕐 Transaksi Terakhir',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  if (transactions.isEmpty)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Text('Belum ada transaksi'),
                      ),
                    )
                  else ...[
                    ...transactions.reversed.take(3).map((item) {
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.blue.shade100,
                          child: Text(
                            item.qty.toString(),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.blue,
                            ),
                          ),
                        ),
                        title: Text(item.name),
                        subtitle: Text(Helpers.formatDate(item.date)),
                        trailing: Text(
                          Helpers.formatCurrency(item.total),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                      );
                    }),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
    required bool isDark,
  }) {
    return Expanded(
      child: Card(
        color: isDark ? Colors.grey.shade800 : Colors.white,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    Text(
                      value,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}