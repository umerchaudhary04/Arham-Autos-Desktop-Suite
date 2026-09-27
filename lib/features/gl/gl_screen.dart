import 'package:flutter/material.dart';
import '../../core/localization/l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/db/database.dart';
import '../../core/security/auth_provider.dart';
import 'package:uuid/uuid.dart';
import 'package:drift/drift.dart' as drift;

final coaProvider = FutureProvider<List<ChartOfAccount>>((ref) async {
  final db = ref.watch(databaseProvider);
  if (db == null) return [];
  return db.select(db.chartOfAccounts).get();
});

class GlScreen extends ConsumerStatefulWidget {
  const GlScreen({super.key});

  @override
  ConsumerState<GlScreen> createState() => _GlScreenState();
}

class _GlScreenState extends ConsumerState<GlScreen> {
  void _showAddAccountDialog() {
    final nameCtrl = TextEditingController();
    String type = 'Expense';

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.addAccount),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameCtrl,
              decoration: InputDecoration(labelText: AppLocalizations.of(context)!.accountName),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: type,
              items: ['Asset', 'Liability', 'Equity', 'Revenue', 'Expense']
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
              onChanged: (v) => type = v!,
              decoration: InputDecoration(labelText: AppLocalizations.of(context)!.type),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text(AppLocalizations.of(context)!.cancel)),
          ElevatedButton(
            onPressed: () async {
              if (nameCtrl.text.isEmpty) {
                ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(content: Text(AppLocalizations.of(context)!.error)));
                return;
              }
              final db = ref.read(databaseProvider)!;
              try {
                await db.into(db.chartOfAccounts).insert(ChartOfAccountsCompanion.insert(
                  accountId: const Uuid().v4(),
                  accountName: nameCtrl.text,
                  accountType: type,
                ));
                ref.invalidate(coaProvider);
                if (ctx.mounted) Navigator.pop(ctx);
              } catch (e) {
                debugPrint('Error inserting account: $e');
                if (ctx.mounted) {
                  ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(content: Text('${AppLocalizations.of(context)!.error}: $e')));
                }
              }
            },
            child: Text(AppLocalizations.of(context)!.save),
          ),
        ],
      ),
    );
  }

  void _showRecordTransactionDialog() async {
    final db = ref.read(databaseProvider);
    if (db == null) return;
    final accounts = await db.select(db.chartOfAccounts).get();
    if (accounts.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Add an account first')));
      return;
    }

    String accountId = accounts.first.accountId;
    final amountCtrl = TextEditingController();
    final descCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.recordTransaction),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<String>(
              value: accountId,
              items: accounts
                  .map((e) => DropdownMenuItem(value: e.accountId, child: Text('${e.accountName} (${e.accountType})')))
                  .toList(),
              onChanged: (v) => accountId = v!,
              decoration: InputDecoration(labelText: AppLocalizations.of(context)!.itemPart),
            ),
            TextField(
              controller: amountCtrl,
              decoration: InputDecoration(labelText: AppLocalizations.of(context)!.amount),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: descCtrl,
              decoration: InputDecoration(labelText: AppLocalizations.of(context)!.description),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text(AppLocalizations.of(context)!.cancel)),
          ElevatedButton(
            onPressed: () async {
              final amt = double.tryParse(amountCtrl.text);
              if (amt == null) {
                ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(content: Text(AppLocalizations.of(context)!.error)));
                return;
              }
              
              final user = ref.read(authProvider).user;
              final recordedBy = user?.id ?? 'system';
              
              try {
                await db.transaction(() async {
                  await db.into(db.glTransactions).insert(GlTransactionsCompanion.insert(
                    transactionId: const Uuid().v4(),
                    accountId: accountId,
                    amount: amt,
                    transactionType: 'Journal',
                    description: drift.Value(descCtrl.text),
                    recordedBy: recordedBy,
                  ));
                  
                  // Also update balance
                  final acc = accounts.firstWhere((a) => a.accountId == accountId);
                  await (db.update(db.chartOfAccounts)..where((a) => a.accountId.equals(accountId))).write(
                    ChartOfAccountsCompanion(currentBalance: drift.Value(acc.currentBalance + amt)),
                  );
                });
                
                ref.invalidate(coaProvider);
                if (ctx.mounted) Navigator.pop(ctx);
              } catch (e) {
                debugPrint('Error recording transaction: $e');
                if (ctx.mounted) {
                  ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(content: Text('${AppLocalizations.of(context)!.error}: $e')));
                }
              }
            },
            child: Text(AppLocalizations.of(context)!.save),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final coaAsync = ref.watch(coaProvider);

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(AppLocalizations.of(context)!.accountsExpenses, style: Theme.of(context).textTheme.headlineMedium),
              Row(
                children: [
                  ElevatedButton.icon(
                    icon: const Icon(Icons.add),
                    label: Text(AppLocalizations.of(context)!.addAccount),
                    onPressed: _showAddAccountDialog,
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.receipt),
                    label: Text(AppLocalizations.of(context)!.recordTransaction),
                    onPressed: _showRecordTransactionDialog,
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: coaAsync.when(
              data: (accounts) {
                if (accounts.isEmpty) return const Center(child: Text('No accounts found.'));
                return DataTable(
                  columns: [
                    DataColumn(label: Text('Account Name')),
                    DataColumn(label: Text('Type')),
                    DataColumn(label: Text('Balance')),
                  ],
                  rows: accounts.map((a) => DataRow(cells: [
                    DataCell(Text(a.accountName)),
                    DataCell(Text(a.accountType)),
                    DataCell(Text(a.currentBalance.toStringAsFixed(2))),
                  ])).toList(),
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
