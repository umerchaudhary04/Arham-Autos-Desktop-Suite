import 'dart:io';

void main() {
  final file = File('lib/features/pos/pos_billing_screen.dart');
  var content = file.readAsStringSync();
  
  if (!content.contains("import 'package:drift/drift.dart';")) {
    content = content.replaceFirst("import '../../core/db/database.dart';", "import '../../core/db/database.dart';\nimport 'package:drift/drift.dart';");
  }
  
  file.writeAsStringSync(content);
}
