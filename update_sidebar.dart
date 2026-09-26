import 'dart:io';

void main() async {
  final file = File('lib/features/admin/sidebar_shell.dart');
  var content = await file.readAsString();

  // Add the AppLocalizations import if missing
  if (!content.contains('package:flutter_gen/gen_l10n/app_localizations.dart')) {
    content = content.replaceFirst(
      "import '../../core/security/auth_provider.dart';", 
      "import 'package:flutter_gen/gen_l10n/app_localizations.dart';\nimport '../../core/security/auth_provider.dart';"
    );
  }
  
  // Replace the _NavItem structure with the new ordered one
  final navItemsRegex = RegExp(r'final navItems = <_NavItem>\[(.*?)\];', dotAll: true);
  
  final newNavItems = '''final navItems = <_NavItem>[
      _NavItem(
        icon: Icons.dashboard,
        label: AppLocalizations.of(context)!.navDashboard,
        screen: const DashboardScreen(),
      ),
      _NavItem(
        icon: Icons.point_of_sale,
        label: AppLocalizations.of(context)!.navPosBilling,
        screen: const PosBillingScreen(),
      ),
      _NavItem(
        icon: Icons.inventory_2,
        label: AppLocalizations.of(context)!.navPartsCatalog,
        screen: const PartsCatalogScreen(),
      ),
      _NavItem(
        icon: Icons.book,
        label: AppLocalizations.of(context)!.navKhataLedger,
        screen: const KhataLedgerScreen(),
      ),
      if (isManager)
        _NavItem(
          icon: Icons.local_shipping,
          label: AppLocalizations.of(context)!.navGrn,
          screen: const GrnScreen(),
        ),
      _NavItem(
        icon: Icons.assignment_return,
        label: AppLocalizations.of(context)!.navReturns,
        screen: const ReturnsClaimsScreen(),
      ),
      if (isManager)
        _NavItem(
          icon: Icons.account_balance,
          label: AppLocalizations.of(context)!.navAccounts,
          screen: const GlScreen(),
        ),
      if (isManager)
        _NavItem(
          icon: Icons.people,
          label: AppLocalizations.of(context)!.navEmployees,
          screen: const HrScreen(),
        ),
      if (isAdmin)
        _NavItem(
          icon: Icons.map,
          label: AppLocalizations.of(context)!.navAreas,
          screen: const AreaScreen(),
        ),
      if (isManager)
        _NavItem(
          icon: Icons.analytics,
          label: AppLocalizations.of(context)!.navReports,
          screen: const ReportsScreen(),
        ),
      if (isAdmin)
        _NavItem(
          icon: Icons.backup,
          label: AppLocalizations.of(context)!.navBackup,
          screen: const BackupRestoreScreen(),
        ),
      if (isAdmin)
        _NavItem(
          icon: Icons.settings,
          label: AppLocalizations.of(context)!.navSettings,
          screen: const SettingsScreen(),
        ),
    ];''';
    
  content = content.replaceFirst(navItemsRegex, newNavItems);
  
  await file.writeAsString(content);
  print('sidebar_shell.dart updated successfully.');
}
