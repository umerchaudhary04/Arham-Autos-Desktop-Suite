import 'package:flutter_test/flutter_test.dart';
import 'package:drift/native.dart';
import 'package:arham_autos/core/db/database.dart';
import 'package:arham_autos/core/db/daos/pos_dao.dart';
import 'package:drift/drift.dart';

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

  test('FIFO batch consumption logic and COGS calculation', () async {
    // 1. Seed parts
    await database.into(database.autoParts).insert(
      AutoPartsCompanion.insert(
        partId: 'part_1',
        partName: 'Brake Pad',
        minReorderLevel: const Value(5),
      )
    );

    // 2. Seed 2 FIFO batches
    await database.into(database.fifoInventoryBatches).insert(
      FifoInventoryBatchesCompanion.insert(
        batchId: 'batch_1',
        partId: 'part_1',
        originalQuantity: 10,
        remainingQuantity: 10,
        unitLandedCost: 100.0,
        receivedAt: Value(DateTime(2023, 1, 1)),
      )
    );
    await database.into(database.fifoInventoryBatches).insert(
      FifoInventoryBatchesCompanion.insert(
        batchId: 'batch_2',
        partId: 'part_1',
        originalQuantity: 10,
        remainingQuantity: 10,
        unitLandedCost: 150.0,
        receivedAt: Value(DateTime(2023, 1, 2)),
      )
    );

    // 3. Process sale of 15 items
    final invoiceId = await posDao.processSale(
      userId: 'user_1',
      customerId: null,
      items: [
        CartItem(partId: 'part_1', quantity: 15, unitPrice: 200.0),
      ],
      discount: 0,
      totalAmount: 3000,
      finalAmount: 3000,
    );

    // 4. Verify DB state
    final invoiceItems = await database.select(database.invoiceItems).get();
    expect(invoiceItems.length, 2, reason: 'Should split across 2 batches');
    
    final item1 = invoiceItems.firstWhere((i) => i.batchId == 'batch_1');
    expect(item1.quantity, 10);
    expect(item1.unitCogs, 100.0);
    
    final item2 = invoiceItems.firstWhere((i) => i.batchId == 'batch_2');
    expect(item2.quantity, 5);
    expect(item2.unitCogs, 150.0);

    final batch1 = await (database.select(database.fifoInventoryBatches)..where((b) => b.batchId.equals('batch_1'))).getSingle();
    expect(batch1.remainingQuantity, 0);

    final batch2 = await (database.select(database.fifoInventoryBatches)..where((b) => b.batchId.equals('batch_2'))).getSingle();
    expect(batch2.remainingQuantity, 5);
  });
}
