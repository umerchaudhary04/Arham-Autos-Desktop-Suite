import 'dart:io';

void main() async {
  final file = File('C:\\Users\\Umer\\Documents\\Arham Autos\\Arham_Autos\\lib\\features\\admin\\settings_screen.dart');
  var content = await file.readAsString();

  // Remove areasListProvider
  content = content.replaceAll(RegExp(r'final areasListProvider = FutureProvider<List<Area>>\(\(ref\) async {.*?}\);\n\n', dotAll: true), '');

  // Remove _showAddAreaDialog
  content = content.replaceAll(RegExp(r'  void _showAddAreaDialog\(\) {.*?}\n\n', dotAll: true), '');

  // Remove Area Management UI block
  content = content.replaceAll(RegExp(r'          const SizedBox\(height: 16\);\n          Row\(\n            mainAxisAlignment: MainAxisAlignment\.spaceBetween,\n            children: \[\n              Text\(\'Area Management\', style: Theme\.of\(context\)\.textTheme\.titleLarge\),\n              ElevatedButton\.icon\(\n                icon: const Icon\(Icons\.map\),\n                label: const Text\(\'Add Area\'\),\n                onPressed: _showAddAreaDialog,\n              \),\n            \],\n          \),\n          const SizedBox\(height: 8\);\n          Expanded\(\n            child: ref\.watch\(areasListProvider\)\.when\(\n              data: \(areas\) {.*?\n              error: \(e, st\) => Center\(child: Text\(\'Error: \$e\'\)\),\n            \),\n          \),\n', dotAll: true), '');

  await file.writeAsString(content);
  print('Removed Area logic from settings');
}
