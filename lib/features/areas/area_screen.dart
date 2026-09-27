import 'package:flutter/material.dart';
import '../../core/localization/l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/db/database.dart';
import '../../core/security/auth_provider.dart';
import 'package:uuid/uuid.dart';
import 'package:drift/drift.dart' as drift;

final areasListProvider = FutureProvider<List<Area>>((ref) async {
  final db = ref.watch(databaseProvider);
  if (db == null) return [];
  return db.select(db.areas).get();
});

class AreaScreen extends ConsumerStatefulWidget {
  const AreaScreen({super.key});

  @override
  ConsumerState<AreaScreen> createState() => _AreaScreenState();
}

class _AreaScreenState extends ConsumerState<AreaScreen> {
  void _showAddAreaDialog() {
    final nameCtrl = TextEditingController();
    final cityCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text(AppLocalizations.of(context)!.addArea),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nameCtrl, decoration: InputDecoration(labelText: AppLocalizations.of(context)!.areaName)),
              TextField(controller: cityCtrl, decoration: InputDecoration(labelText: AppLocalizations.of(context)!.city)),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: Text(AppLocalizations.of(context)!.cancel)),
            ElevatedButton(
              onPressed: () async {
                if (nameCtrl.text.isEmpty) {
                  ScaffoldMessenger.of(ctx).showSnackBar(const SnackBar(content: Text(AppLocalizations.of(context)!.error)));
                  return;
                }
                
                final db = ref.read(databaseProvider)!;
                try {
                  await db.into(db.areas).insert(AreasCompanion.insert(
                    areaId: const Uuid().v4(),
                    areaName: nameCtrl.text,
                    city: drift.Value(cityCtrl.text),
                  ));
                  ref.invalidate(areasListProvider);
                  if (ctx.mounted) Navigator.pop(ctx);
                } catch (e) {
                  debugPrint('Error inserting area: $e');
                  if (ctx.mounted) {
                    ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(content: Text('${AppLocalizations.of(context)!.error}: $e')));
                  }
                }
              },
              child: Text(AppLocalizations.of(context)!.saveArea),
            ),
          ],
        );
      }
    );
  }

  @override
  Widget build(BuildContext context) {
    final areasAsync = ref.watch(areasListProvider);

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(AppLocalizations.of(context)!.areaManagement, style: Theme.of(context).textTheme.headlineMedium),
              ElevatedButton.icon(
                icon: const Icon(Icons.map),
                label: const Text('Add Area'),
                onPressed: _showAddAreaDialog,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: areasAsync.when(
              data: (areas) {
                if (areas.isEmpty) return const Center(child: Text('No areas defined.'));
                return ListView.builder(
                  itemCount: areas.length,
                  itemBuilder: (context, index) {
                    final area = areas[index];
                    return Card(
                      child: ListTile(
                        leading: const Icon(Icons.location_on),
                        title: Text(area.areaName),
                        subtitle: Text(area.city ?? ''),
                      ),
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, st) => Center(child: Text('${AppLocalizations.of(context)!.error}: $e')),
            ),
          ),
        ],
      ),
    );
  }
}
