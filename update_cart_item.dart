import 'dart:io';

void main() {
  final file = File('lib/core/db/daos/pos_dao.dart');
  var content = file.readAsStringSync();
  content = content.replaceFirst('class CartItem {', 'class CartItem {\n  final String? partName;');
  content = content.replaceFirst('required this.unitPrice,', 'required this.unitPrice,\n    this.partName,');
  file.writeAsStringSync(content);
  
  final file2 = File('lib/features/pos/pos_provider.dart');
  var content2 = file2.readAsStringSync();
  content2 = content2.replaceAll('void addItem(String partId, int quantity, double unitPrice)', 'void addItem(String partId, int quantity, double unitPrice, {String? partName})');
  content2 = content2.replaceAll('CartItem(\n        partId: partId,\n        quantity: existingItem.quantity + quantity,\n        unitPrice: existingItem\n            .unitPrice', 'CartItem(\n        partId: partId,\n        partName: partName ?? existingItem.partName,\n        quantity: existingItem.quantity + quantity,\n        unitPrice: existingItem\n            .unitPrice');
  content2 = content2.replaceAll('CartItem(partId: partId, quantity: quantity, unitPrice: unitPrice)', 'CartItem(partId: partId, quantity: quantity, unitPrice: unitPrice, partName: partName)');
  file2.writeAsStringSync(content2);
}
