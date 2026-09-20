import 'dart:io';

void main() async {
  final file = File('C:\\Users\\Umer\\Documents\\Arham Autos\\Arham_Autos\\lib\\features\\admin\\sidebar_shell.dart');
  var content = await file.readAsString();

  content = content.replaceFirst(
    "import '../import/import_wizard_screen.dart';",
    "import '../areas/area_screen.dart';"
  );

  content = content.replaceFirst(
'''      if (isAdmin)
        _NavItem(
          icon: Icons.import_export,
          label: 'Legacy Import Wizard',
          screen: const ImportWizardScreen(),
        ),''',
'''      if (isAdmin)
        _NavItem(
          icon: Icons.map,
          label: 'Areas',
          screen: const AreaScreen(),
        ),'''
  );

  await file.writeAsString(content);
  print('Updated sidebar shell.');
}
