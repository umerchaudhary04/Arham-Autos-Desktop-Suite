import 'dart:async';
import 'package:flutter/material.dart';
import '../../core/localization/l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:drift/drift.dart' as drift;
import '../../core/security/admin_pin_modal.dart';
import '../../core/security/auth_provider.dart';
import '../../core/db/database.dart';

class PartsSearchQueryNotifier extends Notifier<String> {
  Timer? _debounceTimer;

  @override
  String build() {
    ref.onDispose(() {
      _debounceTimer?.cancel();
    });
    return '';
  }

  void setQuery(String query) {
    if (_debounceTimer?.isActive ?? false) {
      _debounceTimer!.cancel();
    }
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      state = query;
    });
  }
}

final partsSearchQueryProvider =
    NotifierProvider<PartsSearchQueryNotifier, String>(
      () => PartsSearchQueryNotifier(),
    );

final partsListProvider = FutureProvider<List<AutoPart>>((ref) async {
  final query = ref.watch(partsSearchQueryProvider);
  final db = ref.watch(databaseProvider);
  if (db == null) return [];
  return db.partsDao.searchParts(query);
});

class PartsCatalogScreen extends ConsumerStatefulWidget {
  const PartsCatalogScreen({super.key});

  @override
  ConsumerState<PartsCatalogScreen> createState() => _PartsCatalogScreenState();
}

class _PartsCatalogScreenState extends ConsumerState<PartsCatalogScreen> {
  void _showAddPartDialog() {
    final nameCtrl = TextEditingController();
    final oemCtrl = TextEditingController();
    final modelCtrl = TextEditingController();
    final rackCtrl = TextEditingController();
    final reorderCtrl = TextEditingController(text: '0');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.addNewPart),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameCtrl,
                decoration: InputDecoration(labelText: AppLocalizations.of(context)!.partName),
              ),
              TextField(
                controller: oemCtrl,
                decoration: InputDecoration(labelText: AppLocalizations.of(context)!.oemNumber),
              ),
              TextField(
                controller: modelCtrl,
                decoration: InputDecoration(labelText: AppLocalizations.of(context)!.model),
              ),
              TextField(
                controller: rackCtrl,
                decoration: InputDecoration(labelText: AppLocalizations.of(context)!.rackLocation),
              ),
              TextField(
                controller: reorderCtrl,
                decoration: const InputDecoration(
                  labelText: AppLocalizations.of(context)!.minReorderLevel,
                ),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
          ElevatedButton(
            onPressed: () async {
              if (nameCtrl.text.isEmpty) return;
              final db = ref.read(databaseProvider)!;
              await db
                  .into(db.autoParts)
                  .insert(
                    AutoPartsCompanion.insert(
                      partId: const Uuid().v4(),
                      partName: nameCtrl.text,
                      oemNumber: drift.Value(
                        oemCtrl.text.isEmpty ? null : oemCtrl.text,
                      ),
                      model: drift.Value(
                        modelCtrl.text.isEmpty ? null : modelCtrl.text,
                      ),
                      rackLocation: drift.Value(
                        rackCtrl.text.isEmpty ? null : rackCtrl.text,
                      ),
                      minReorderLevel: drift.Value(
                        int.tryParse(reorderCtrl.text) ?? 0,
                      ),
                    ),
                  );
              ref.invalidate(partsListProvider);
              Navigator.pop(ctx);
            },
            child: Text(AppLocalizations.of(context)!.savePart),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final partsAsync = ref.watch(partsListProvider);
    final user = ref.watch(authProvider).user;
    final isManager = user?.role == 'Manager' || user?.role == 'Admin';

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Parts Catalog & Inventory',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              if (isManager)
                ElevatedButton.icon(
                  icon: const Icon(Icons.add),
                  label: Text(AppLocalizations.of(context)!.addNewPart),
                  onPressed: _showAddPartDialog,
                ),
            ],
          ),
          const SizedBox(height: 16),
          TextField(
            decoration: const InputDecoration(
              labelText: AppLocalizations.of(context)!.searchParts,
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.search),
            ),
            onChanged: (val) =>
                ref.read(partsSearchQueryProvider.notifier).setQuery(val),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: partsAsync.when(
              data: (parts) {
                if (parts.isEmpty)
                  return const Center(child: Text('No parts found.'));
                return ListView.builder(
                  itemCount: parts.length,
                  itemBuilder: (context, index) {
                    final part = parts[index];
                    return ListTile(
                      title: Text(part.partName),
                      subtitle: Text(
                        'OEM: ${part.oemNumber ?? "N/A"} | Model: ${part.model ?? "N/A"} | Rack: ${part.rackLocation ?? "N/A"}',
                      ),
                      trailing: isManager
                          ? ElevatedButton(
                              onPressed: () async {
                                final auth = await AdminPinModal.show(
                                  context,
                                  'Manual Stock Adjustment for ${part.partName}',
                                );
                                if (!context.mounted) return;
                                if (auth)
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Authorized. (Structural Mock)',
                                      ),
                                    ),
                                  );
                              },
                              child: Text(AppLocalizations.of(context)!.adjustStock),
                            )
                          : null,
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
