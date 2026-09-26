import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/security/auth_provider.dart';
import '../../core/db/database.dart';
import '../areas/area_screen.dart'; // To get areasListProvider
import 'package:uuid/uuid.dart';
import 'package:drift/drift.dart' as drift;

class LedgerTypeNotifier extends Notifier<String> {
  @override
  String build() => 'Customer';
  void setType(String type) => state = type;
}

final ledgerTypeProvider = NotifierProvider<LedgerTypeNotifier, String>(
  () => LedgerTypeNotifier(),
);

final ledgerAccountsProvider = FutureProvider<List<AccountsLedgerData>>((
  ref,
) async {
  final type = ref.watch(ledgerTypeProvider);
  final db = ref.watch(databaseProvider);
  if (db == null) return [];
  return db.ledgerDao.getAccountsByType(type);
});

class KhataLedgerScreen extends ConsumerStatefulWidget {
  const KhataLedgerScreen({super.key});

  @override
  ConsumerState<KhataLedgerScreen> createState() => _KhataLedgerScreenState();
}

class _KhataLedgerScreenState extends ConsumerState<KhataLedgerScreen> {
  void _showAddAccountDialog(String selectedType, List<Area>? areas) {
    final nameCtrl = TextEditingController();
    final limitCtrl = TextEditingController(text: '100000');
    String? selectedAreaId;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Text('Add $selectedType'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameCtrl,
                  decoration: const InputDecoration(labelText: 'Account Name'),
                ),
                TextField(
                  controller: limitCtrl,
                  decoration: const InputDecoration(labelText: 'Credit Limit'),
                  keyboardType: TextInputType.number,
                ),
                if (selectedType == 'Customer' && areas != null && areas.isNotEmpty)
                  DropdownButtonFormField<String>(
                    value: selectedAreaId,
                    hint: const Text('Select Area (Optional)'),
                    items: areas.map((a) => DropdownMenuItem(
                      value: a.areaId,
                      child: Text(a.areaName),
                    )).toList(),
                    onChanged: (v) => setState(() => selectedAreaId = v),
                  ),
              ],
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
              ElevatedButton(
                onPressed: () async {
                  if (nameCtrl.text.isEmpty) {
                    ScaffoldMessenger.of(ctx).showSnackBar(const SnackBar(content: Text('Name is required')));
                    return;
                  }
                  
                  final limit = double.tryParse(limitCtrl.text);
                  if (limit == null) {
                    ScaffoldMessenger.of(ctx).showSnackBar(const SnackBar(content: Text('Invalid credit limit')));
                    return;
                  }

                  final db = ref.read(databaseProvider)!;
                  try {
                    await db.into(db.accountsLedger).insert(AccountsLedgerCompanion.insert(
                      accountId: const Uuid().v4(),
                      accountName: nameCtrl.text,
                      accountType: selectedType,
                      currentBalance: 0.0,
                      creditLimit: drift.Value(limit),
                      areaId: drift.Value(selectedAreaId),
                    ));
                    
                    ref.invalidate(ledgerAccountsProvider);
                    if (ctx.mounted) Navigator.pop(ctx);
                  } catch (e) {
                    debugPrint('Error inserting account: $e');
                    if (ctx.mounted) {
                      ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(content: Text('Failed to save account: $e')));
                    }
                  }
                },
                child: const Text('Save'),
              ),
            ],
          );
        }
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ledgerAsync = ref.watch(ledgerAccountsProvider);
    final selectedType = ref.watch(ledgerTypeProvider);
    final user = ref.watch(authProvider).user;
    
    // Watch areas so they are ready when we open the dialog
    final areasAsync = ref.watch(areasListProvider);

    final canAdd = user?.role == 'Admin' || user?.role == 'Manager';

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Khata Ledger',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              Row(
                children: [
                  SegmentedButton<String>(
                    segments: const [
                      ButtonSegment(value: 'Customer', label: Text('Customers')),
                      ButtonSegment(value: 'Supplier', label: Text('Suppliers')),
                    ],
                    selected: {selectedType},
                    onSelectionChanged: (Set<String> newSelection) {
                      ref
                          .read(ledgerTypeProvider.notifier)
                          .setType(newSelection.first);
                    },
                  ),
                  if (canAdd) ...[
                    const SizedBox(width: 16),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.add),
                      label: Text('Add $selectedType'),
                      onPressed: () {
                        final areas = areasAsync.valueOrNull;
                        _showAddAccountDialog(selectedType, areas);
                      },
                    ),
                  ],
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),

          Expanded(
            child: ledgerAsync.when(
              data: (accounts) {
                if (accounts.isEmpty) {
                  return Center(
                    child: Text('No $selectedType accounts found.'),
                  );
                }
                return ListView.builder(
                  itemCount: accounts.length,
                  itemBuilder: (context, index) {
                    final acc = accounts[index];
                    final limit =
                        acc.creditLimit ?? 100000.0; // Mock limit if null
                    final progress = limit > 0 ? (acc.currentBalance / limit) : 0.0;

                    return Card(
                      child: ListTile(
                        title: Text(acc.accountName),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Balance: ₨ ${acc.currentBalance} / Limit: ₨ $limit',
                            ),
                            const SizedBox(height: 4),
                            LinearProgressIndicator(
                              value: progress.clamp(0.0, 1.0),
                              color: progress > 0.9
                                  ? Colors.red
                                  : (progress > 0.7
                                        ? Colors.orange
                                        : Colors.green),
                            ),
                          ],
                        ),
                        trailing: ElevatedButton(
                          onPressed: () {
                            // Structural mock for viewing details
                          },
                          child: const Text('View Ledger'),
                        ),
                      ),
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, st) => Center(child: Text('Error: $e')),
            ),
          ),
        ],
      ),
    );
  }
}
