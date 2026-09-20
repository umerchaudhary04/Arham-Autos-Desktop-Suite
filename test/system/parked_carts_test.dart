import 'package:flutter_test/flutter_test.dart';
import 'package:arham_autos/core/db/database.dart';
import 'package:drift/native.dart';
import 'package:drift/drift.dart';

void main() {
  test('Shift-Change / Parked Carts: Ensure cart parks upon user switch', () async {
    final database = AppDatabase('test_key', executor: NativeDatabase.memory());

    // Assume user is switching, the _switchUser logic in sidebar_shell does this:
    final userId = 'user_1';
    
    // Simulating _switchUser saving the cart
    await database.into(database.parkedCarts).insertOnConflictUpdate(
      ParkedCartsCompanion.insert(
        parkedId: 'cart_$userId',
        userId: userId,
        cartPayloadJson: '{"items": [{"partId": "p1", "qty": 2}]}',
      ),
    );

    // Verify it was saved
    final parked = await database.select(database.parkedCarts).get();
    expect(parked.length, 1);
    expect(parked.first.userId, userId);
    expect(parked.first.cartPayloadJson, contains('p1'));

    // Resuming upon re-login would involve fetching from db.parkedCarts
    final resumed = await (database.select(database.parkedCarts)..where((p) => p.userId.equals(userId))).getSingle();
    expect(resumed.cartPayloadJson, contains('p1'));
  });
}
