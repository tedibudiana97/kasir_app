import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/transaction_model.dart';
import '../services/database_service.dart';
import '../utils/helpers.dart';

class ReportScreen extends StatefulWidget {
  const ReportScreen({super.key});

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  List<TransactionModel> transactions = [];
  List<TransactionModel> filteredTransactions = [];
  String selectedMonth = '';
  int selectedYear = DateTime.now().year;
  bool isLoading = true;

  final List<String> months = [
    'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
    'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
  ];

  @override
  void initState() {
    super.initState();
    selectedMonth = months[DateTime.now().month - 1];
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => isLoading = true);
    final data = await DatabaseService.getTransactions();
    setState(() {
      transactions = data;
      _applyFilter();
      isLoading = false;
    });
  }

  void _applyFilter() {
    final monthIndex = months.indexOf(selectedMonth) + 1;
    setState(() {
      filteredTransactions = transactions.where((item) {
        try {
          final date = DateTime.parse(item.date);
          return date.month == monthIndex && date.year == selectedYear;
        } catch (e) {
          return false;
        }
      }).toList();
    });
  }

  int get totalItems {
    int total = 0;
    for (var item in filteredTransactions) {
      total += item.qty;
    }
    return total;
  }

  double get totalAmount {
    double total = 0;
    for (var item in filteredTransactions) {
      total += item.total;
    }
    return total;
  }

  Map<String, double> get categoryData {
    Map<String, double> data = {};
    for (var item in filteredTransactions) {
      data[item.category] = (data[item.category] ?? 0) + item.total;
    }
    return data;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final data = categoryData;

    return Column(
      children: [
        // Filter Bulan & Tahun
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.grey.shade800 : Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: isDark ? Colors.grey.shade700 : Colors.grey.shade300),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: selectedMonth,
                      isExpanded: true,
                      icon: const Icon(Icons.arrow_drop_down, color: Colors.blue),
                      style: TextStyle(
                        color: isDark ? Colors.white : Colors.black87,
                        fontSize: 14,
                      ),
                      items: months.map((month) {
                        return DropdownMenuItem(
                          value: month,
                          child: Text(month),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedMonth = value!;
                          _applyFilter();
                        });
                      },
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.grey.shade800 : Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: isDark ? Colors.grey.shade700 : Colors.grey.shade300),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<int>(
                      value: selectedYear,
                      isExpanded: true,
                      icon: const Icon(Icons.arrow_drop_down, color: Colors.blue),
                      style: TextStyle(
                        color: isDark ? Colors.white : Colors.black87,
                        fontSize: 14,
                      ),
                      items: [2023, 2024, 2025, 2026].map((year) {
                        return DropdownMenuItem(
                          value: year,
                          child: Text(year.toString()),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedYear = value!;
                          _applyFilter();
                        });
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        
        // Statistik
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Expanded(
                child: Card(
                  color: isDark ? Colors.grey.shade800 : Colors.blue.shade50,
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      children: [
                        const Text('📊 Transaksi',
                            style: TextStyle(fontSize: 12, color: Colors.grey)),
                        Text('${filteredTransactions.length}',
                            style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue)),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Card(
                  color: isDark ? Colors.grey.shade800 : Colors.green.shade50,
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      children: [
                        const Text('💰 Pendapatan',
                            style: TextStyle(fontSize: 12, color: Colors.grey)),
                        Text(Helpers.formatCurrency(totalAmount),
                            style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.green)),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 8),
        
        // Grafik
        Expanded(
          child: Card(
            margin: const EdgeInsets.all(16),
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '📈 Statistik Kategori',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Text(
                        'Total Item: ',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                      Text(
                        '$totalItems',
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: data.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.inbox,
                                  size: 64,
                                  color: Colors.grey.shade400,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Belum ada data untuk bulan ini',
                                  style: TextStyle(
                                    color: Colors.grey.shade400,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : BarChart(
                            BarChartData(
                              alignment: BarChartAlignment.spaceAround,
                              maxY: data.isEmpty
                                  ? 1
                                  : data.values.reduce((a, b) => a > b ? a : b) * 1.2,
                              barGroups: data.entries.map((entry) {
                                final index = data.keys.toList().indexOf(entry.key);
                                return BarChartGroupData(
                                  x: index,
                                  barRods: [
                                    BarChartRodData(
                                      toY: entry.value,
                                      color: Colors.primaries[index % Colors.primaries.length],
                                      width: 30,
                                      borderRadius: const BorderRadius.vertical(
                                          top: Radius.circular(8)),
                                      backDrawRodData: BackgroundBarChartRodData(
                                        show: true,
                                        toY: entry.value,
                                        color: Colors.primaries[index %
                                                Colors.primaries.length]
                                            .withOpacity(0.1),
                                      ),
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
                                      final keys = data.keys.toList();
                                      if (index >= 0 && index < keys.length) {
                                        return Padding(
                                          padding: const EdgeInsets.only(top: 8),
                                          child: Text(
                                            keys[index].length > 6
                                                ? '${keys[index].substring(0, 6)}..'
                                                : keys[index],
                                            style: const TextStyle(fontSize: 10),
                                          ),
                                        );
                                      }
                                      return const Text('');
                                    },
                                  ),
                                ),
                                leftTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    reservedSize: 40,
                                    getTitlesWidget: (value, meta) {
                                      return Text(
                                        Helpers.formatCurrency(value),
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
        ),
      ],
    );
  }
}