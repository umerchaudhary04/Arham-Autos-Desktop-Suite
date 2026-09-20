import 'package:flutter_test/flutter_test.dart';
import 'package:arham_autos/core/db/database.dart';
import 'package:drift/native.dart';
import 'package:drift/drift.dart';
import 'package:arham_autos/features/returns/returns_service.dart';

void main() {
  test('Returns Workflow: Operator initiate -> Admin approve -> FIFO stock return', () async {
    final database = AppDatabase('test_key', executor: NativeDatabase.memory());
    final returnsService = ReturnsService(database);

    // Seed Data
    final customerId = 'cust_1';
    await database.into(database.accountsLedger).insert(
      AccountsLedgerCompanion.insert(
        accountId: customerId,
        accountName: 'Return Customer',
        accountType: 'Customer',
        currentBalance: const Value(100.0), // owes 100
      )
    );

    await database.into(database.fifoInventoryBatches).insert(
      FifoInventoryBatchesCompanion.insert(
        batchId: 'batch_1',
        partId: 'part_1',
        originalQuantity: 10,
        remainingQuantity: 5, // 5 were sold
        unitLandedCost: 10.0,
      )
    );

    final invoiceId = 'inv_1';
    await database.into(database.salesInvoices).insert(
      SalesInvoicesCompanion.insert(
        invoiceId: invoiceId,
        customerId: Value(customerId),
        totalAmount: 100.0,
        finalAmount: 100.0,
        createdBy: 'operator_1',
      )
    );

    final itemId = 'item_1';
    await database.into(database.invoiceItems).insert(
      InvoiceItemsCompanion.insert(
        itemId: itemId,
        invoiceId: invoiceId,
        partId: 'part_1',
        batchId: 'batch_1',
        quantity: 5,
        unitPrice: 20.0,
        unitCogs: 10.0,
      )
    );

    // 1. Operator initiates return
    await returnsService.submitReturnClaim(
      invoiceId: invoiceId,
      userId: 'operator_1',
      itemsReturned: [
        {'itemId': itemId, 'qty': 2, 'reason': 'defective'}
      ]
    );

    // Verify stock is NOT returned yet
    var batch = await (database.select(database.fifoInventoryBatches)..where((b) => b.batchId.equals('batch_1'))).getSingle();
    expect(batch.remainingQuantity, 5); // Still 5

    // Verify claim is pending
    final pendingClaims = await returnsService.getPendingClaims();
    expect(pendingClaims.length, 1);
    final claimId = pendingClaims.first.claim.claimId;

    // 2. Admin approves return and issues Khata Credit
    await returnsService.approveReturnClaim(
      claimId: claimId,
      adminUserId: 'admin_1',
      refundMethod: 'Khata Credit'
    );

    // 3. Verify stock IS returned
    batch = await (database.select(database.fifoInventoryBatches)..where((b) => b.batchId.equals('batch_1'))).getSingle();
    expect(batch.remainingQuantity, 7); // 5 + 2

    // 4. Verify Customer balance is credited (reduced by 2 * 20 = 40)
    final customer = await (database.select(database.accountsLedger)..where((a) => a.accountId.equals(customerId))).getSingle();
    expect(customer.currentBalance, 60.0); // 100 - 40 = 60
  });
}
