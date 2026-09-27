import 'dart:io';

void main() {
  final file = File('lib/core/db/daos/reports_dao.dart');
  var content = file.readAsStringSync();
  
  if (content.startsWith('class RecentSaleDto')) {
    final idx = content.indexOf("import 'package:drift/drift.dart';");
    if (idx != -1) {
      final dtos = content.substring(0, idx);
      final rest = content.substring(idx);
      final newContent = rest.replaceFirst("part 'reports_dao.g.dart';", "part 'reports_dao.g.dart';\n\n" + dtos);
      file.writeAsStringSync(newContent);
    }
  }
}
