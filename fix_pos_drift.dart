import 'dart:io';

void main() {
  final file = File('lib/features/pos/pos_billing_screen.dart');
  var content = file.readAsStringSync();
  
  content = content.replaceFirst("import 'package:drift/drift.dart';", "import 'package:drift/drift.dart' hide Column;\nimport '../../core/security/auth_provider.dart';");
  
  file.writeAsStringSync(content);
}
