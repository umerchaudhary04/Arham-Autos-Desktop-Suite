import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:arham_autos/core/db/database.dart';
import 'package:drift/native.dart';
import 'package:arham_autos/features/reports/export_service.dart';

void main() {
  test('Data Export & Audit Log: Verify exports write successfully to audit_log', () async {
    final database = AppDatabase('test_key', executor: NativeDatabase.memory());
    final exportService = ExportService(database);

    final rows = [
      ['ID', 'Name', 'Qty'],
      ['1', 'Part A', 10],
      ['2', 'Part B', 20],
    ];

    final path = await exportService.exportToCsv('admin_1', rows, 'test_export');
    
    // Verify file created
    final file = File(path);
    expect(file.existsSync(), isTrue);
    
    // Cleanup file
    if (file.existsSync()) {
      file.deleteSync();
    }

    // Verify Audit Log
    final logs = await database.select(database.auditLog).get();
    expect(logs.length, 1);
    
    final log = logs.first;
    expect(log.userId, 'admin_1');
    expect(log.actionType, 'DATA_EXPORT');
    expect(log.newValue, 'Exported test_export to CSV');
  });
}
