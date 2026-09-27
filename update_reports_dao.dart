import 'dart:io';

void main() {
  final file = File('lib/core/db/daos/reports_dao.dart');
  var content = file.readAsStringSync();
  
  if (!content.contains('AutoParts')) {
    content = content.replaceFirst(
      '@DriftAccessor(tables: [SalesInvoices, InvoiceItems])',
      '@DriftAccessor(tables: [SalesInvoices, InvoiceItems, AutoParts])'
    );
  }
  
  final additions = """
class RecentSaleDto {
  final String partName;
  final int quantity;
  final double totalValue;
  final DateTime date;
  
  RecentSaleDto({required this.partName, required this.quantity, required this.totalValue, required this.date});
}

class DailySalesDto {
  final DateTime date;
  final double sales;
  
  DailySalesDto({required this.date, required this.sales});
}
""";

  if (!content.contains('RecentSaleDto')) {
    content = additions + "\n" + content;
  }
  
  final methodAdditions = """
  Future<List<RecentSaleDto>> getRecentSales() async {
    final query = select(invoiceItems).join([
      innerJoin(salesInvoices, salesInvoices.invoiceId.equalsExp(invoiceItems.invoiceId)),
      innerJoin(db.autoParts, db.autoParts.partId.equalsExp(invoiceItems.partId)),
    ])
      ..orderBy([OrderingTerm(expression: salesInvoices.createdAt, mode: OrderingMode.desc)])
      ..limit(10);
      
    final rows = await query.get();
    return rows.map((row) {
      final item = row.readTable(invoiceItems);
      final inv = row.readTable(salesInvoices);
      final part = row.readTable(db.autoParts);
      
      return RecentSaleDto(
        partName: part.partName,
        quantity: item.quantity,
        totalValue: item.quantity * item.unitPrice,
        date: inv.createdAt,
      );
    }).toList();
  }
  
  Future<List<DailySalesDto>> getWeeklySalesPerformance() async {
    final now = DateTime.now();
    final startOf7DaysAgo = DateTime(now.year, now.month, now.day).subtract(const Duration(days: 6));
    
    final invoices = await (select(salesInvoices)..where((i) => i.createdAt.isBiggerOrEqualValue(startOf7DaysAgo))).get();
    
    // Group by day
    Map<String, double> salesByDay = {};
    for (int i = 0; i < 7; i++) {
      final d = startOf7DaysAgo.add(Duration(days: i));
      salesByDay["\${d.year}-\${d.month.toString().padLeft(2, '0')}-\${d.day.toString().padLeft(2, '0')}"] = 0.0;
    }
    
    for (var inv in invoices) {
      final d = inv.createdAt;
      final key = "\${d.year}-\${d.month.toString().padLeft(2, '0')}-\${d.day.toString().padLeft(2, '0')}";
      if (salesByDay.containsKey(key)) {
        salesByDay[key] = (salesByDay[key] ?? 0.0) + inv.finalAmount;
      }
    }
    
    return salesByDay.entries.map((e) => DailySalesDto(date: DateTime.parse(e.key), sales: e.value)).toList();
  }
""";

  if (!content.contains('getRecentSales')) {
    content = content.replaceFirst(
      'return totalProfit;\n  }\n}',
      'return totalProfit;\n  }\n\n' + methodAdditions + '\n}'
    );
  }
  
  file.writeAsStringSync(content);
}
