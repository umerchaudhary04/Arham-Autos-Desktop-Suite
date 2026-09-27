import 'dart:io';

void main() {
  final file = File('lib/features/reports/dashboard_screen.dart');
  var content = file.readAsStringSync();
  
  if (!content.contains('package:fl_chart/fl_chart.dart')) {
    content = content.replaceFirst(
      "import 'export_service.dart';",
      "import 'export_service.dart';\nimport 'package:fl_chart/fl_chart.dart';\nimport 'package:intl/intl.dart';\nimport '../../core/db/daos/reports_dao.dart';"
    );
  }
  
  final newProviders = """
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
""";

  if (!content.contains('weeklySalesPerformanceProvider')) {
    content = content.replaceFirst(
      'final todaySalesProvider = FutureProvider<double>((ref) async {',
      newProviders + '\nfinal todaySalesProvider = FutureProvider<double>((ref) async {'
    );
  }
  
  file.writeAsStringSync(content);
}
