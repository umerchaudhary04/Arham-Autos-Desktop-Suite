import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:arham_autos/core/db/database.dart';
import 'package:arham_autos/core/security/auth_provider.dart';
import 'package:arham_autos/features/pos/pos_provider.dart';
import 'package:arham_autos/features/pos/print_service.dart';
import 'package:drift/native.dart';

class MockPrintService extends PrintService {
  bool printed = false;
  
  @override
  Future<void> printInvoiceSilently(String invoiceId, int paperWidthMm, Map<String, dynamic> invoiceData) async {
    printed = true;
  }
}

class MockAuthNotifier extends AuthNotifier {
  @override
  AuthState build() {
    return AuthState(
      user: LocalUser(
        id: 'admin_1',
        username: 'admin',
        fullName: 'Admin User',
        passwordHash: 'hash',
        pinHash: 'pin',
        role: 'Admin',
        preferredLanguage: 'en',
      ),
      isLocked: false,
    );
  }
}

void main() {
  test('POS Billing Flow Integration: DB write -> PDF render -> Print', () async {
    final database = AppDatabase('test_key', executor: NativeDatabase.memory());
    final mockPrint = MockPrintService();

    final container = ProviderContainer(
      overrides: [
        printServiceProvider.overrideWithValue(mockPrint),
        authProvider.overrideWith(() => MockAuthNotifier()),
      ],
    );

    // Provide database state manually
    container.read(databaseProvider.notifier).setDatabase(database);

    // 1. Seed database with customer, part, and inventory
    final customerId = 'cust_1';
    await database.into(database.accountsLedger).insert(
      AccountsLedgerCompanion.insert(
        accountId: customerId,
        accountName: 'John Doe',
        accountType: 'Customer',
      )
    );
    await database.into(database.autoParts).insert(
      AutoPartsCompanion.insert(
        partId: 'part_1',
        partName: 'Spark Plug',
      )
    );
    await database.into(database.fifoInventoryBatches).insert(
      FifoInventoryBatchesCompanion.insert(
        batchId: 'batch_1',
        partId: 'part_1',
        originalQuantity: 50,
        remainingQuantity: 50,
        unitLandedCost: 50.0,
      )
    );

    // 2. Add item to POS Cart
    final posCart = container.read(posCartProvider.notifier);
    posCart.setCustomer(customerId);
    posCart.addItem('part_1', 10, 100.0);
    posCart.setDiscount(50.0);

    // Subtotal should be 10 * 100 = 1000. Discount 50. Total 950.
    expect(container.read(posCartProvider).subtotal, 1000.0);
    expect(container.read(posCartProvider).total, 950.0);

    // 3. Checkout
    final success = await posCart.checkout();
    expect(success, isTrue);

    // 4. Verify DB writes
    final batch = await (database.select(database.fifoInventoryBatches)..where((b) => b.batchId.equals('batch_1'))).getSingle();
    expect(batch.remainingQuantity, 40); // 50 - 10

    final customer = await (database.select(database.accountsLedger)..where((a) => a.accountId.equals(customerId))).getSingle();
    expect(customer.currentBalance, 950.0); // Billed on credit

    final invoices = await database.select(database.salesInvoices).get();
    expect(invoices.length, 1);
    expect(invoices.first.finalAmount, 950.0);

    // 5. Verify PDF print was called
    expect(mockPrint.printed, isTrue);
    
    // 6. Verify cart is cleared
    expect(container.read(posCartProvider).items, isEmpty);
  });
}
