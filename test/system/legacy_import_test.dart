import 'package:flutter_test/flutter_test.dart';
import 'package:arham_autos/core/db/database.dart';
import 'package:drift/native.dart';
import 'package:arham_autos/features/import/legacy_import_service.dart';

void main() {
  test('Legacy Import Wizard: Field mapping and auto-skipping of invalid records', () async {
    final database = AppDatabase('test_key', executor: NativeDatabase.memory());
    final service = LegacyImportService(database, 'admin_1');

    final dummyRawData = {
      'Items': [
        // Valid item
        {'PartName': 'Brake Pad', 'OEM': 'BP-123', 'Model': 'Honda', 'Rack': 'A1'},
        // Invalid item (missing PartName)
        {'PartName': '', 'OEM': 'BP-456'},
        {'PartName': null, 'Model': 'Toyota'},
      ]
    };

    final result = service.validateAndMap(dummyRawData);
    final validParts = result['validParts'] as List<Map<String, dynamic>>;
    final skippedRecords = result['skippedRecords'] as List<Map<String, dynamic>>;

    expect(validParts.length, 1);
    expect(validParts.first['partName'], 'Brake Pad');
    expect(validParts.first['oemNumber'], 'BP-123');

    expect(skippedRecords.length, 2);

    // Commit import
    final partsWithStock = validParts.map((p) => {
      ...p,
      'openingQuantity': 10,
      'openingCost': 50.0,
    }).toList();

    await service.commitImport(partsWithStock, skippedRecords);

    // Verify DB
    final parts = await database.select(database.autoParts).get();
    expect(parts.length, 1);
    expect(parts.first.partName, 'Brake Pad');

    final batches = await database.select(database.fifoInventoryBatches).get();
    expect(batches.length, 1);
    expect(batches.first.remainingQuantity, 10);
    expect(batches.first.unitLandedCost, 50.0);

    final logs = await database.select(database.migrationLog).get();
    expect(logs.length, 1);
    expect(logs.first.recordsImported, 1);
    expect(logs.first.recordsFlagged, 2);
  });
}
