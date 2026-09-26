import 'package:flutter_test/flutter_test.dart';
import 'package:arham_autos/core/db/database.dart';
import 'package:drift/native.dart';
import 'package:drift/drift.dart' as drift;
import 'package:uuid/uuid.dart';

void main() {
  test('GL Transaction insert test', () async {
    final db = AppDatabase('test_key', executor: NativeDatabase.memory());
    
    // Create an account
    final accountId = const Uuid().v4();
    await db.into(db.chartOfAccounts).insert(ChartOfAccountsCompanion.insert(
      accountId: accountId,
      accountName: 'Cash',
      accountType: 'Asset',
    ));
    
    // Create a transaction
    try {
      await db.into(db.glTransactions).insert(GlTransactionsCompanion.insert(
        transactionId: const Uuid().v4(),
        accountId: accountId,
        amount: 500.0,
        transactionType: 'Journal',
        description: const drift.Value('Test'),
        recordedBy: 'system',
      ));
      
      final txs = await db.select(db.glTransactions).get();
      expect(txs.length, 1);
      print('GL Transaction insert successful');
    } catch (e, st) {
      print('Error during GL Transaction insert: $e');
      print(st);
      fail('Insert failed');
    }
  });

  test('Employee insert test', () async {
    final db = AppDatabase('test_key', executor: NativeDatabase.memory());
    
    try {
      await db.into(db.employees).insert(EmployeesCompanion.insert(
        employeeId: const Uuid().v4(),
        fullName: 'Test Employee',
        jobTitle: const drift.Value('Manager'),
        currentSalary: const drift.Value(5000.0),
      ));
      
      final emps = await db.select(db.employees).get();
      expect(emps.length, 1);
      print('Employee insert successful');
    } catch (e, st) {
      print('Error during Employee insert: $e');
      print(st);
      fail('Insert failed');
    }
  });
}
