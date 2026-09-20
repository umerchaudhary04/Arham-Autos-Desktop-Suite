import 'package:flutter_test/flutter_test.dart';
import 'package:arham_autos/core/db/database.dart';
import 'package:drift/native.dart';
import 'package:arham_autos/core/db/daos/ledger_dao.dart';
import 'package:drift/drift.dart';

void main() {
  test('GRN Flow: Create new FIFO batches and update supplier ledger', () async {
    final database = AppDatabase('test_key', executor: NativeDatabase.memory());
    final ledgerDao = LedgerDao(database);

    // 1. Seed Supplier
    final supplierId = 'supp_1';
    await database.into(database.accountsLedger).insert(
      AccountsLedgerCompanion.insert(
        accountId: supplierId,
        accountName: 'ABC Auto Parts',
        accountType: 'Supplier',
        currentBalance: const Value(0.0),
      )
    );

    // 2. Add Parts
    await database.into(database.autoParts).insert(
      AutoPartsCompanion.insert(
        partId: 'part_1',
        partName: 'Brake Pad',
      )
    );
    await database.into(database.autoParts).insert(
      AutoPartsCompanion.insert(
        partId: 'part_2',
        partName: 'Oil Filter',
      )
    );

    // 3. Receive Goods
    await ledgerDao.receiveGoods(
      supplierId,
      [
        GrnItem(partId: 'part_1', quantity: 20, landedCost: 80.0),
        GrnItem(partId: 'part_2', quantity: 50, landedCost: 40.0),
      ],
      3600.0 // (20*80) + (50*40) = 1600 + 2000 = 3600
    );

    // 4. Verify FIFO batches were created
    final batches = await database.select(database.fifoInventoryBatches).get();
    expect(batches.length, 2);
    
    final b1 = batches.firstWhere((b) => b.partId == 'part_1');
    expect(b1.remainingQuantity, 20);
    expect(b1.unitLandedCost, 80.0);
    expect(b1.supplierId, supplierId);

    final b2 = batches.firstWhere((b) => b.partId == 'part_2');
    expect(b2.remainingQuantity, 50);
    expect(b2.unitLandedCost, 40.0);
    expect(b2.supplierId, supplierId);

    // 5. Verify Supplier Ledger updated (Credit means they gave us goods, balance increases)
    final supplier = await (database.select(database.accountsLedger)..where((a) => a.accountId.equals(supplierId))).getSingle();
    expect(supplier.currentBalance, 3600.0);
  });
}
