import 'package:drift/drift.dart' hide Column;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/db/database.dart';
import '../../core/security/auth_provider.dart';
import '../../core/security/idle_lock_provider.dart';
import '../../main.dart'; // for localeProvider
import '../../core/localization/l10n/app_localizations.dart';
import 'package:uuid/uuid.dart';
import 'package:drift/drift.dart' as drift;

final usersListProvider = FutureProvider<List<LocalUser>>((ref) async {
  final db = ref.watch(databaseProvider);
  if (db == null) return [];
  return db.usersDao.getAllUsers();
});

final auditLogProvider = FutureProvider<List<AuditLogData>>((ref) async {
  final db = ref.watch(databaseProvider);
  if (db == null) return [];
  return (db.select(db.auditLog)..orderBy([(t) => OrderingTerm.desc(t.createdAt)])).get();
});

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  void _showAddOrEditUserDialog([LocalUser? user]) {
    final loc = AppLocalizations.of(context)!;
    final usernameCtrl = TextEditingController(text: user?.username ?? '');
    final fullnameCtrl = TextEditingController(text: user?.fullName ?? '');
    final passwordCtrl = TextEditingController();
    final pinCtrl = TextEditingController();
    String selectedRole = user?.role ?? 'Operator';

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: Text(user == null ? loc.addUser : loc.editUser),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(controller: usernameCtrl, decoration: InputDecoration(labelText: loc.username)),
                    TextField(controller: fullnameCtrl, decoration: InputDecoration(labelText: loc.fullName)),
                    TextField(
                      controller: passwordCtrl, 
                      decoration: InputDecoration(labelText: '${loc.password}${user != null ? " (Leave blank to keep current)" : ""}'), 
                      obscureText: true
                    ),
                    TextField(
                      controller: pinCtrl, 
                      decoration: InputDecoration(labelText: '${loc.pin}${user != null ? " (Leave blank to keep current)" : ""}'), 
                      obscureText: true
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: selectedRole,
                      decoration: InputDecoration(labelText: loc.role),
                      items: const [
                        DropdownMenuItem(value: 'Admin', child: Text('Admin')),
                        DropdownMenuItem(value: 'Manager', child: Text('Manager')),
                        DropdownMenuItem(value: 'Operator', child: Text('Operator')),
                      ],
                      onChanged: (v) {
                        if (v != null) setStateDialog(() => selectedRole = v);
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(ctx), child: Text(loc.cancel)),
                ElevatedButton(
                  onPressed: () async {
                    if (usernameCtrl.text.isEmpty || fullnameCtrl.text.isEmpty) return;
                    if (user == null && (passwordCtrl.text.isEmpty || pinCtrl.text.isEmpty)) return;
                    
                    final db = ref.read(databaseProvider)!;
                    
                    if (user == null) {
                      await db.into(db.localUsers).insert(LocalUsersCompanion.insert(
                        id: const Uuid().v4(),
                        fullName: fullnameCtrl.text,
                        username: usernameCtrl.text,
                        passwordHash: passwordCtrl.text, 
                        pinHash: pinCtrl.text,
                        role: selectedRole,
                      ));
                    } else {
                      await db.update(db.localUsers).replace(
                        user.copyWith(
                          fullName: fullnameCtrl.text,
                          username: usernameCtrl.text,
                          role: selectedRole,
                          passwordHash: passwordCtrl.text.isNotEmpty ? passwordCtrl.text : user.passwordHash,
                          pinHash: pinCtrl.text.isNotEmpty ? pinCtrl.text : user.pinHash,
                        )
                      );
                    }
                    
                    ref.invalidate(usersListProvider);
                    Navigator.pop(ctx);
                  },
                  child: Text(loc.save),
                ),
              ],
            );
          }
        );
      }
    );
  }

  void _showDeleteUserDialog(LocalUser user) {
    final loc = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text(loc.deleteUser),
          content: Text('${loc.deleteUserConfirm}\n\n${user.username} (${user.role})'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: Text(loc.cancel)),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
              onPressed: () async {
                final db = ref.read(databaseProvider)!;
                await (db.delete(db.localUsers)..where((u) => u.id.equals(user.id))).go();
                ref.invalidate(usersListProvider);
                Navigator.pop(ctx);
              },
              child: Text(loc.delete),
            ),
          ],
        );
      }
    );
  }

  void _showAuditLog() {
    final loc = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (ctx) {
        return Dialog(
          child: Container(
            width: 800,
            height: 600,
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(loc.viewAuditLog, style: Theme.of(context).textTheme.headlineSmall),
                    IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(ctx)),
                  ],
                ),
                const Divider(),
                Expanded(
                  child: Consumer(
                    builder: (context, ref, child) {
                      final logsAsync = ref.watch(auditLogProvider);
                      return logsAsync.when(
                        data: (logs) {
                          return ListView.builder(
                            itemCount: logs.length,
                            itemBuilder: (ctx, i) {
                              final log = logs[i];
                              return ListTile(
                                title: Text('${log.actionType} - ${log.targetTable ?? ''}'),
                                subtitle: Text('${log.createdAt} | User: ${log.userId} | ${log.newValue ?? ''}'),
                              );
                            },
                          );
                        },
                        loading: () => const Center(child: CircularProgressIndicator()),
                        error: (e, st) => Center(child: Text('Error: $e')),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      }
    );
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final usersAsync = ref.watch(usersListProvider);
    final idleLockDuration = ref.watch(idleLockProvider);
    final currentLocale = ref.watch(localeProvider);

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(loc.settingsTitle, style: Theme.of(context).textTheme.headlineMedium),
              ElevatedButton.icon(
                icon: const Icon(Icons.language),
                label: Text('${loc.languageToggle}: ${currentLocale.languageCode == 'en' ? 'English' : 'Urdu'}'),
                onPressed: () async {
                  final newLocale = currentLocale.languageCode == 'en' ? const Locale('ur') : const Locale('en');
                  ref.read(localeProvider.notifier).setLocale(newLocale);
                  
                  // Update DB for current user so preference is saved
                  final user = ref.read(authProvider).user;
                  if (user != null) {
                    final db = ref.read(databaseProvider)!;
                    await db.update(db.localUsers).replace(
                      user.copyWith(preferredLanguage: newLocale.languageCode)
                    );
                    ref.read(authProvider.notifier).updateUserLanguage(newLocale.languageCode);
                  }
                },
              ),
            ],
          ),
          const SizedBox(height: 16),

          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(loc.securityConfig, style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(loc.idleTimeout),
                      DropdownButton<int>(
                        value: (idleLockDuration ~/ 60),
                        items: [1, 5, 15, 30, 60].map((int val) {
                          return DropdownMenuItem<int>(value: val, child: Text('$val'));
                        }).toList(),
                        onChanged: (newVal) {
                          if (newVal != null) ref.read(idleLockProvider.notifier).updateTimeout(newVal * 60);
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(loc.userManagement, style: Theme.of(context).textTheme.titleLarge),
              ElevatedButton.icon(
                icon: const Icon(Icons.person_add),
                label: Text(loc.addUser),
                onPressed: () => _showAddOrEditUserDialog(),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Expanded(
            child: usersAsync.when(
              data: (users) {
                return ListView.builder(
                  itemCount: users.length,
                  itemBuilder: (context, index) {
                    final u = users[index];
                    return Card(
                      child: ListTile(
                        title: Text(u.username),
                        subtitle: Text('${loc.role}: ${u.role} | ${loc.fullName}: ${u.fullName}'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.blue),
                              onPressed: () => _showAddOrEditUserDialog(u),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _showDeleteUserDialog(u),
                            ),
                          ],
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

          const SizedBox(height: 16),
          ElevatedButton.icon(
            icon: const Icon(Icons.list_alt),
            onPressed: _showAuditLog,
            label: Text(loc.viewAuditLog),
          ),
        ],
      ),
    );
  }
}
