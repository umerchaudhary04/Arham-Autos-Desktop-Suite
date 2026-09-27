import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/security/auth_provider.dart';

import 'export_service.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../core/db/daos/reports_dao.dart';
import '../../core/db/database.dart';

final weeklySalesPerformanceProvider = FutureProvider<List<DailySalesDto>>((ref) async {
  final db = ref.watch(databaseProvider);
  if (db == null) return [];
  return db.reportsDao.getWeeklySalesPerformance();
});

final recentSalesProvider = FutureProvider<List<RecentSaleDto>>((ref) async {
  final db = ref.watch(databaseProvider);
  if (db == null) return [];
  return db.reportsDao.getRecentSales();
});

final todaySalesProvider = FutureProvider<double>((ref) async {
  final db = ref.watch(databaseProvider);
  if (db == null) return 0.0;
  return db.reportsDao.getTodaySales();
});

final todayProfitProvider = FutureProvider<double>((ref) async {
  final db = ref.watch(databaseProvider);
  if (db == null) return 0.0;
  return db.reportsDao.getTodayProfit();
});

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).user;
    if (user == null) return const SizedBox.shrink();

    final isOperator = user.role == 'Operator';
    final isAdmin = user.role == 'Admin';

    final salesAsync = ref.watch(todaySalesProvider);
    final profitAsync = ref.watch(todayProfitProvider);
    final weeklySalesAsync = ref.watch(weeklySalesPerformanceProvider);
    final recentSalesAsync = ref.watch(recentSalesProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Dashboard',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              if (isAdmin) // Restricted entirely to Admin
                ElevatedButton.icon(
                  onPressed: () async {
                    final db = ref.read(databaseProvider);
                    if (db == null) return;
                    
                    final sales = await db.reportsDao.getTodaySales();
                    final profit = await db.reportsDao.getTodayProfit();
                    
                    final rows = [
                      ['Metric', 'Value'],
                      ['Today Sales', sales],
                      ['Today Profit', profit],
                      ['Margin', sales > 0 ? (profit/sales).toStringAsFixed(2) : 0]
                    ];
                    
                    final svc = ExportService(db);
                    try {
                      final path = await svc.exportToCsv(user.id, rows, 'Dashboard_Report');
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Exported to $path')),
                        );
                      }
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Export failed: $e')),
                        );
                      }
                    }
                  },
                  icon: const Icon(Icons.download),
                  label: const Text('Export Reports'),
                ),
            ],
          ),
          const SizedBox(height: 24),

          if (isOperator) ...[
            // Operator View: Today's Sales only, no profit margins
            Card(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Today's Sales",
                      style: TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                    const SizedBox(height: 8),
                    salesAsync.when(
                      data: (sales) => Text(
                        "Rs $sales",
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      loading: () => const CircularProgressIndicator(),
                      error: (e, st) => const Text('Error'),
                    ),
                  ],
                ),
              ),
            ),
          ] else ...[
            // Admin/Manager View
            Row(
              children: [
                _buildKpiCard(
                  "Today's Sales",
                  salesAsync.when(
                    data: (sales) => "Rs $sales",
                    loading: () => "...",
                    error: (e, st) => "Err",
                  ),
                ),
                const SizedBox(width: 16),
                _buildKpiCard(
                  "Gross Profit",
                  profitAsync.when(
                    data: (profit) => "Rs $profit",
                    loading: () => "...",
                    error: (e, st) => "Err",
                  ),
                  isHighlight: true,
                ),
                const SizedBox(width: 16),
                _buildKpiCard(
                  "Receivables",
                  "Rs 0",
                ), // Placeholder for Receivables
                const SizedBox(width: 16),
                _buildKpiCard(
                  "Low Stock",
                  "0 items",
                  isAlert: true,
                ), // Placeholder for Low Stock
              ],
            ),
            const SizedBox(height: 32),
            
            // Performance Overview Chart
            Text(
              'Performance Overview',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: SizedBox(
                  height: 300,
                  child: weeklySalesAsync.when(
                    data: (data) {
                      if (data.isEmpty) return const Center(child: Text("No data"));
                      return BarChart(
                        BarChartData(
                          alignment: BarChartAlignment.spaceAround,
                          maxY: data.map((e) => e.sales).reduce((a, b) => a > b ? a : b) * 1.2,
                          titlesData: FlTitlesData(
                            show: true,
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                getTitlesWidget: (value, meta) {
                                  if (value.toInt() >= 0 && value.toInt() < data.length) {
                                    final date = data[value.toInt()].date;
                                    return Padding(
                                      padding: const EdgeInsets.only(top: 8.0),
                                      child: Text(DateFormat('E').format(date)),
                                    );
                                  }
                                  return const Text('');
                                },
                              ),
                            ),
                            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          ),
                          borderData: FlBorderData(show: false),
                          barGroups: data.asMap().entries.map((entry) {
                            return BarChartGroupData(
                              x: entry.key,
                              barRods: [
                                BarChartRodData(
                                  toY: entry.value.sales,
                                  color: Colors.blueAccent,
                                  width: 22,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ],
                            );
                          }).toList(),
                        ),
                      );
                    },
                    loading: () => const Center(child: CircularProgressIndicator()),
                    error: (e, st) => Center(child: Text('Error loading chart: $e')),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Recent Sales List
            Text(
              'Recent Sales',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Card(
              child: recentSalesAsync.when(
                data: (sales) {
                  if (sales.isEmpty) return const Padding(padding: EdgeInsets.all(24.0), child: Text("No recent sales."));
                  return ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: sales.length,
                    separatorBuilder: (context, index) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final sale = sales[index];
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.blue.shade50,
                          child: const Icon(Icons.shopping_bag, color: Colors.blue),
                        ),
                        title: Text(sale.partName),
                        subtitle: Text(DateFormat('MMM dd, yyyy - hh:mm a').format(sale.date)),
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text("Rs \${sale.totalValue.toStringAsFixed(2)}", style: const TextStyle(fontWeight: FontWeight.bold)),
                            Text("Qty: \${sale.quantity}", style: const TextStyle(fontSize: 12, color: Colors.grey)),
                          ],
                        ),
                      );
                    },
                  );
                },
                loading: () => const Padding(padding: EdgeInsets.all(24.0), child: Center(child: CircularProgressIndicator())),
                error: (e, st) => Padding(padding: const EdgeInsets.all(24.0), child: Text('Error loading recent sales: $e')),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildKpiCard(
    String title,
    String value, {
    bool isHighlight = false,
    bool isAlert = false,
  }) {
    return Expanded(
      child: Card(
        color: isHighlight
            ? Colors.teal.shade50
            : (isAlert ? Colors.amber.shade50 : null),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(fontSize: 18, color: Colors.grey),
              ),
              const SizedBox(height: 8),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
