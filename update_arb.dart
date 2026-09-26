import 'dart:convert';
import 'dart:io';

void main() async {
  final enFile = File('lib/core/localization/l10n/en.arb');
  final urFile = File('lib/core/localization/l10n/ur.arb');

  final enData = {
    "appTitle": "Arham Autos Desktop Suite",
    "@appTitle": {
      "description": "The title of the application"
    },
    "navDashboard": "Dashboard",
    "navPosBilling": "POS Billing",
    "navPartsCatalog": "Parts Catalog",
    "navKhataLedger": "Khata Ledger",
    "navGrn": "Purchases / GRN",
    "navReturns": "Returns & Claims",
    "navAccounts": "Accounts & Expenses",
    "navEmployees": "Employees",
    "navAreas": "Areas",
    "navReports": "Reports",
    "navBackup": "Backup & Restore",
    "navSettings": "Settings",
    "settingsTitle": "Admin Settings",
    "languageToggle": "Language",
    "securityConfig": "Security Configuration",
    "idleTimeout": "Idle Auto-Lock Timeout (minutes):",
    "userManagement": "User Management",
    "addUser": "Add User",
    "editUser": "Edit User",
    "deleteUser": "Delete User",
    "deleteUserConfirm": "Are you sure you want to delete this user?",
    "cancel": "Cancel",
    "save": "Save",
    "delete": "Delete",
    "username": "Username",
    "fullName": "Full Name",
    "password": "Password",
    "pin": "PIN (4 digits)",
    "role": "Role",
    "viewAuditLog": "View System Audit Log"
  };

  final urData = {
    "appTitle": "ارحم آٹوز ڈیسک ٹاپ سویٹ",
    "navDashboard": "ڈیش بورڈ",
    "navPosBilling": "پی او ایس بلنگ",
    "navPartsCatalog": "پارٹس کیٹلاگ",
    "navKhataLedger": "کھاتہ لیجر",
    "navGrn": "خریداری / جی آر این",
    "navReturns": "واپسی اور کلیمز",
    "navAccounts": "اکاؤنٹس اور اخراجات",
    "navEmployees": "ملازمین",
    "navAreas": "علاقے",
    "navReports": "رپورٹس",
    "navBackup": "بیک اپ اور ری اسٹور",
    "navSettings": "ترتیبات",
    "settingsTitle": "ایڈمن ترتیبات",
    "languageToggle": "زبان",
    "securityConfig": "سیکیورٹی کنفیگریشن",
    "idleTimeout": "آٹو لاک ٹائم آؤٹ (منٹ):",
    "userManagement": "یوزر مینجمنٹ",
    "addUser": "یوزر شامل کریں",
    "editUser": "یوزر میں ترمیم کریں",
    "deleteUser": "یوزر حذف کریں",
    "deleteUserConfirm": "کیا آپ واقعی اس صارف کو حذف کرنا چاہتے ہیں؟",
    "cancel": "منسوخ کریں",
    "save": "محفوظ کریں",
    "delete": "حذف کریں",
    "username": "یوزر نیم",
    "fullName": "پورا نام",
    "password": "پاس ورڈ",
    "pin": "پن (4 ہندسے)",
    "role": "رول (Role)",
    "viewAuditLog": "سسٹم آڈٹ لاگ دیکھیں"
  };

  await enFile.writeAsString(const JsonEncoder.withIndent('  ').convert(enData));
  await urFile.writeAsString(const JsonEncoder.withIndent('  ').convert(urData));
  
  print('ARB files updated successfully.');
}
