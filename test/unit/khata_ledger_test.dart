import 'package:flutter_test/flutter_test.dart';
import 'package:drift/native.dart';
import 'package:arham_autos/core/db/database.dart';
import 'package:arham_autos/core/db/daos/pos_dao.dart';
import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

void main() {
  late AppDatabase database;
  late PosDao posDao;

  setUp(() {
    database = AppDatabase('test_key', executor: NativeDatabase.memory());
    posDao = PosDao(database);
  });

  tearDown(() async {
    await database.close();
  });

  test('Khata Ledger double-entry integrity, credit limit enforcement, and balance updates', () async {
    final customerId = const Uuid().v4();
    
    // 1. Seed customer with credit limit of 5000
    await database.into(database.accountsLedger).insert(
      AccountsLedgerCompanion.insert(
        accountId: customerId,
        accountName: 'Test Customer',
        accountType: 'Customer',
        currentBalance: const Value(0.0),
        creditLimit: const Value(5000.0),
      )
    );

    // 2. Add part to sell
    await database.into(database.autoParts).insert(
      AutoPartsCompanion.insert(
        partId: 'part_1',
        partName: 'Brake Pad',
        minReorderLevel: const Value(5),
      )
    );
    await database.into(database.fifoInventoryBatches).insert(
      FifoInventoryBatchesCompanion.insert(
        batchId: 'batch_1',
        partId: 'part_1',
        originalQuantity: 10,
        remainingQuantity: 10,
        unitLandedCost: 100.0,
        receivedAt: Value(DateTime.now()),
      )
    );

    // 3. Process sale below limit (3000)
    await posDao.processSale(
      userId: 'user_1',
      customerId: customerId,
      items: [
        CartItem(partId: 'part_1', quantity: 1, unitPrice: 3000.0),
      ],
      discount: 0,
      totalAmount: 3000,
      finalAmount: 3000,
      // bypassCreditLimit: false,
    );

    var account = await (database.select(database.accountsLedger)..where((a) => a.accountId.equals(customerId))).getSingle();
    expect(account.currentBalance, 3000.0);

    // 4. Process sale that exceeds limit (3000 + 3000 = 6000 > 5000)
    try {
      await posDao.processSale(
        userId: 'user_1',
        customerId: customerId,
        items: [
          CartItem(partId: 'part_1', quantity: 1, unitPrice: 3000.0),
        ],
        discount: 0,
        totalAmount: 3000,
        finalAmount: 3000,
        // bypassCreditLimit: false,
      );
      fail('Should have thrown credit limit exception');
    } catch (e) {
      expect(e.toString(), contains('Credit limit exceeded'));
    }

    // Balance should remain unchanged due to atomic transaction rollback
    account = await (database.select(database.accountsLedger)..where((a) => a.accountId.equals(customerId))).getSingle();
    expect(account.currentBalance, 3000.0);
  });
}
