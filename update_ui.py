import os
import json

arb_en = {
    "appTitle": "Arham Autos Desktop Suite",
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
    "viewAuditLog": "View System Audit Log",
    
    # Parts Catalog
    "addNewPart": "Add New Part",
    "partName": "Part Name *",
    "oemNumber": "OEM Number",
    "model": "Model",
    "rackLocation": "Rack Location",
    "minReorderLevel": "Min Reorder Level",
    "savePart": "Save Part",
    "partsCatalogTitle": "Parts Catalog & Inventory",
    "searchParts": "Search by Part Name, OEM #, Model, or Rack",
    "noPartsFound": "No parts found.",
    "adjustStock": "Adjust Stock",
    "authorizedMock": "Authorized. (Structural Mock)",
    
    # Ledger
    "khataLedger": "Khata Ledger",
    "customers": "Customers",
    "suppliers": "Suppliers",
    "addCustomer": "Add Customer",
    "addSupplier": "Add Supplier",
    "accountName": "Account Name",
    "creditLimit": "Credit Limit",
    "selectArea": "Select Area (Optional)",
    "viewLedger": "View Ledger",
    "noAccountsFound": "No accounts found.",
    "balance": "Balance",
    "limit": "Limit",
    
    # GRN
    "recordGrn": "Record Goods Receipt Note (GRN)",
    "selectSupplier": "Select Supplier",
    "selectPart": "Select Part",
    "quantity": "Quantity",
    "unitPrice": "Unit Price",
    "addItem": "Add Item",
    "noItemsGrn": "No items added.",
    "saveGrn": "Save GRN",
    "itemPart": "Item/Part",
    "total": "Total",
    "price": "Price",
    
    # POS
    "posBilling": "POS Billing",
    "searchPartToAdd": "Search part to add...",
    "quantityPos": "Qty",
    "pricePos": "Price (Rs)",
    "parkSale": "Park Sale",
    "recallSale": "Recall Sale",
    "checkout": "Checkout",
    "noItemsPos": "No items in cart.",
    
    # Returns
    "returnsClaims": "Returns & Claims",
    "selectInvoice": "Select Original Invoice",
    "selectMethod": "Refund Method",
    "cash": "Cash",
    "khataCredit": "Khata Credit",
    "approveReturn": "Approve & Process Return",
    "processReturnMock": "Return Processed (Mock)",
    
    # GL
    "accountsExpenses": "Accounts & Expenses",
    "addAccount": "Add Account",
    "recordTransaction": "Record Transaction",
    "type": "Type",
    "description": "Description",
    "amount": "Amount",
    "noAccounts": "No accounts found.",
    
    # HR
    "employeeManagement": "Employee Management",
    "addEmployee": "Add Employee",
    "jobTitle": "Job Title",
    "currentSalary": "Current Salary",
    "saveEmployee": "Save Employee",
    "noEmployees": "No employees found.",
    
    # Area
    "areaManagement": "Area Management",
    "addArea": "Add New Area",
    "areaName": "Area Name",
    "city": "City",
    "saveArea": "Save Area",
    "noAreas": "No areas found.",
    
    # Reports
    "reportsTitle": "Reports & Analytics",
    "dailySales": "Daily Sales Report",
    "inventoryValuation": "Inventory Valuation",
    "customerBalances": "Customer Balances",
    "exportData": "Export Data to CSV",
    
    # Backup
    "backupRestore": "Backup & Restore",
    "createBackup": "Create Backup",
    "restoreBackup": "Restore Backup",
    "selectFile": "Select Backup File",
    "restore": "Restore",
    
    "error": "Error"
}

arb_ur = {
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
    "viewAuditLog": "سسٹم آڈٹ لاگ دیکھیں",
    
    # Parts Catalog
    "addNewPart": "نیا پارٹ شامل کریں",
    "partName": "پارٹ کا نام *",
    "oemNumber": "OEM نمبر",
    "model": "ماڈل",
    "rackLocation": "ریک لوکیشن",
    "minReorderLevel": "کم از کم ری آرڈر لیول",
    "savePart": "محفوظ کریں",
    "partsCatalogTitle": "پارٹس کیٹلاگ اور انوینٹری",
    "searchParts": "پارٹ کا نام، OEM، ماڈل، یا ریک سے تلاش کریں",
    "noPartsFound": "کوئی پارٹس نہیں ملے۔",
    "adjustStock": "اسٹاک ایڈجسٹ کریں",
    "authorizedMock": "تصدیق ہو گئی۔ (ماک)",
    
    # Ledger
    "khataLedger": "کھاتہ لیجر",
    "customers": "کسٹمرز",
    "suppliers": "سپلائرز",
    "addCustomer": "کسٹمر شامل کریں",
    "addSupplier": "سپلائر شامل کریں",
    "accountName": "اکاؤنٹ کا نام",
    "creditLimit": "کریڈٹ کی حد",
    "selectArea": "علاقہ منتخب کریں (اختیاری)",
    "viewLedger": "لیجر دیکھیں",
    "noAccountsFound": "کوئی اکاؤنٹس نہیں ملے۔",
    "balance": "بیلنس",
    "limit": "حد",
    
    # GRN
    "recordGrn": "گڈز رسیپٹ نوٹ (GRN) ریکارڈ کریں",
    "selectSupplier": "سپلائر منتخب کریں",
    "selectPart": "پارٹ منتخب کریں",
    "quantity": "مقدار",
    "unitPrice": "قیمت فی یونٹ",
    "addItem": "آئٹم شامل کریں",
    "noItemsGrn": "کوئی آئٹمز شامل نہیں کی گئیں۔",
    "saveGrn": "GRN محفوظ کریں",
    "itemPart": "آئٹم / پارٹ",
    "total": "کل",
    "price": "قیمت",
    
    # POS
    "posBilling": "پی او ایس بلنگ",
    "searchPartToAdd": "شامل کرنے کے لیے پارٹ تلاش کریں...",
    "quantityPos": "مقدار",
    "pricePos": "قیمت (روپے)",
    "parkSale": "سیل پارک کریں",
    "recallSale": "سیل واپس لائیں",
    "checkout": "چیک آؤٹ",
    "noItemsPos": "کارٹ میں کوئی آئٹمز نہیں ہیں۔",
    
    # Returns
    "returnsClaims": "واپسی اور کلیمز",
    "selectInvoice": "اصل انوائس منتخب کریں",
    "selectMethod": "رقم واپسی کا طریقہ",
    "cash": "کیش",
    "khataCredit": "کھاتہ کریڈٹ",
    "approveReturn": "منظور کریں اور واپسی پروسیس کریں",
    "processReturnMock": "واپسی پروسیس ہو گئی۔ (ماک)",
    
    # GL
    "accountsExpenses": "اکاؤنٹس اور اخراجات",
    "addAccount": "اکاؤنٹ شامل کریں",
    "recordTransaction": "ٹرانزیکشن ریکارڈ کریں",
    "type": "قسم",
    "description": "تفصیل",
    "amount": "رقم",
    "noAccounts": "کوئی اکاؤنٹس نہیں ملے۔",
    
    # HR
    "employeeManagement": "ایمپلائی مینجمنٹ",
    "addEmployee": "ملازم شامل کریں",
    "jobTitle": "عہدہ",
    "currentSalary": "موجودہ تنخواہ",
    "saveEmployee": "محفوظ کریں",
    "noEmployees": "کوئی ملازم نہیں ملا۔",
    
    # Area
    "areaManagement": "علاقہ مینجمنٹ",
    "addArea": "نیا علاقہ شامل کریں",
    "areaName": "علاقے کا نام",
    "city": "شہر",
    "saveArea": "محفوظ کریں",
    "noAreas": "کوئی علاقے نہیں ملے۔",
    
    # Reports
    "reportsTitle": "رپورٹس اور تجزیہ",
    "dailySales": "یومیہ سیلز رپورٹ",
    "inventoryValuation": "انوینٹری ویلیوایشن",
    "customerBalances": "کسٹمر بیلنسز",
    "exportData": "ڈیٹا CSV میں ایکسپورٹ کریں",
    
    # Backup
    "backupRestore": "بیک اپ اور ری اسٹور",
    "createBackup": "بیک اپ بنائیں",
    "restoreBackup": "بیک اپ ری اسٹور کریں",
    "selectFile": "بیک اپ فائل منتخب کریں",
    "restore": "ری اسٹور کریں",
    
    "error": "خرابی"
}

os.makedirs('lib/core/localization/l10n', exist_ok=True)
with open('lib/core/localization/l10n/en.arb', 'w', encoding='utf-8') as f:
    json.dump(arb_en, f, indent=2, ensure_ascii=False)
with open('lib/core/localization/l10n/ur.arb', 'w', encoding='utf-8') as f:
    json.dump(arb_ur, f, indent=2, ensure_ascii=False)

print("Created ARB files.")

# Next: Regex based replacements in the dart files

files_to_update = {
    'lib/features/parts/parts_catalog_screen.dart': [
        ("const Text('Add New Part')", "Text(AppLocalizations.of(context)!.addNewPart)"),
        ("const InputDecoration(labelText: 'Part Name *')", "InputDecoration(labelText: AppLocalizations.of(context)!.partName)"),
        ("const InputDecoration(labelText: 'OEM Number')", "InputDecoration(labelText: AppLocalizations.of(context)!.oemNumber)"),
        ("const InputDecoration(labelText: 'Model')", "InputDecoration(labelText: AppLocalizations.of(context)!.model)"),
        ("const InputDecoration(labelText: 'Rack Location')", "InputDecoration(labelText: AppLocalizations.of(context)!.rackLocation)"),
        ("labelText: 'Min Reorder Level',", "labelText: AppLocalizations.of(context)!.minReorderLevel,"),
        ("const Text('Cancel')", "Text(AppLocalizations.of(context)!.cancel)"),
        ("const Text('Save Part')", "Text(AppLocalizations.of(context)!.savePart)"),
        ("Text('Parts Catalog & Inventory'", "Text(AppLocalizations.of(context)!.partsCatalogTitle"),
        ("const Text('No parts found.')", "Text(AppLocalizations.of(context)!.noPartsFound)"),
        ("labelText: 'Search by Part Name, OEM #, Model, or Rack',", "labelText: AppLocalizations.of(context)!.searchParts,"),
        ("const Text('Adjust Stock')", "Text(AppLocalizations.of(context)!.adjustStock)"),
        ("Text('Authorized. (Structural Mock)',", "Text(AppLocalizations.of(context)!.authorizedMock,"),
        ("Text('Error: $e')", "Text('${AppLocalizations.of(context)!.error}: $e')"),
    ],
    'lib/features/pos/pos_billing_screen.dart': [
        ("const Text('POS Billing')", "Text(AppLocalizations.of(context)!.posBilling)"),
        ("const Text('Park Sale')", "Text(AppLocalizations.of(context)!.parkSale)"),
        ("const Text('Recall Sale')", "Text(AppLocalizations.of(context)!.recallSale)"),
        ("const Text('Checkout')", "Text(AppLocalizations.of(context)!.checkout)"),
        ("const Text('Item Name')", "Text(AppLocalizations.of(context)!.itemPart)"),
        ("const Text('Qty')", "Text(AppLocalizations.of(context)!.quantityPos)"),
        ("const Text('Price (Rs)')", "Text(AppLocalizations.of(context)!.pricePos)"),
        ("const Text('Total')", "Text(AppLocalizations.of(context)!.total)"),
        ("const Text('No items in cart.')", "Text(AppLocalizations.of(context)!.noItemsPos)"),
        ("const InputDecoration(labelText: 'Search part to add...',", "InputDecoration(labelText: AppLocalizations.of(context)!.searchPartToAdd,"),
        ("Text('Error: $e')", "Text('${AppLocalizations.of(context)!.error}: $e')"),
    ],
    'lib/features/reports/reports_screen.dart': [
        ("Text('Reports & Analytics'", "Text(AppLocalizations.of(context)!.reportsTitle"),
        ("const Text('Daily Sales Report')", "Text(AppLocalizations.of(context)!.dailySales)"),
        ("const Text('Inventory Valuation')", "Text(AppLocalizations.of(context)!.inventoryValuation)"),
        ("const Text('Customer Balances')", "Text(AppLocalizations.of(context)!.customerBalances)"),
        ("const Text('Export Data to CSV')", "Text(AppLocalizations.of(context)!.exportData)"),
    ],
    'lib/features/admin/backup_restore_screen.dart': [
        ("Text('Backup & Restore'", "Text(AppLocalizations.of(context)!.backupRestore"),
        ("const Text('Create Backup')", "Text(AppLocalizations.of(context)!.createBackup)"),
        ("const Text('Restore Backup')", "Text(AppLocalizations.of(context)!.restoreBackup)"),
        ("const Text('Select Backup File')", "Text(AppLocalizations.of(context)!.selectFile)"),
        ("const Text('Restore')", "Text(AppLocalizations.of(context)!.restore)"),
    ],
    'lib/features/gl/gl_screen.dart': [
        ("const Text('Add Account')", "Text(AppLocalizations.of(context)!.addAccount)"),
        ("const InputDecoration(labelText: 'Account Name')", "InputDecoration(labelText: AppLocalizations.of(context)!.accountName)"),
        ("const InputDecoration(labelText: 'Type')", "InputDecoration(labelText: AppLocalizations.of(context)!.type)"),
        ("const Text('Cancel')", "Text(AppLocalizations.of(context)!.cancel)"),
        ("const Text('Save')", "Text(AppLocalizations.of(context)!.save)"),
        ("const Text('Record Transaction')", "Text(AppLocalizations.of(context)!.recordTransaction)"),
        ("const InputDecoration(labelText: 'Account')", "InputDecoration(labelText: AppLocalizations.of(context)!.itemPart)"),
        ("const InputDecoration(labelText: 'Amount')", "InputDecoration(labelText: AppLocalizations.of(context)!.amount)"),
        ("const InputDecoration(labelText: 'Description')", "InputDecoration(labelText: AppLocalizations.of(context)!.description)"),
        ("Text('Accounts & Expenses'", "Text(AppLocalizations.of(context)!.accountsExpenses"),
        ("const Text('No accounts found.')", "Text(AppLocalizations.of(context)!.noAccounts)"),
        ("const DataColumn(label: Text('Account Name'))", "DataColumn(label: Text(AppLocalizations.of(context)!.accountName))"),
        ("const DataColumn(label: Text('Type'))", "DataColumn(label: Text(AppLocalizations.of(context)!.type))"),
        ("const DataColumn(label: Text('Balance'))", "DataColumn(label: Text(AppLocalizations.of(context)!.balance))"),
        ("Text('Error: $e')", "Text('${AppLocalizations.of(context)!.error}: $e')"),
    ],
    'lib/features/hr/hr_screen.dart': [
        ("const Text('Add Employee')", "Text(AppLocalizations.of(context)!.addEmployee)"),
        ("const InputDecoration(labelText: 'Full Name')", "InputDecoration(labelText: AppLocalizations.of(context)!.fullName)"),
        ("const InputDecoration(labelText: 'Job Title')", "InputDecoration(labelText: AppLocalizations.of(context)!.jobTitle)"),
        ("const InputDecoration(labelText: 'Current Salary')", "InputDecoration(labelText: AppLocalizations.of(context)!.currentSalary)"),
        ("const Text('Cancel')", "Text(AppLocalizations.of(context)!.cancel)"),
        ("const Text('Save')", "Text(AppLocalizations.of(context)!.save)"),
        ("Text('Employee Management'", "Text(AppLocalizations.of(context)!.employeeManagement"),
        ("const Text('No employees found.')", "Text(AppLocalizations.of(context)!.noEmployees)"),
        ("const DataColumn(label: Text('Full Name'))", "DataColumn(label: Text(AppLocalizations.of(context)!.fullName))"),
        ("const DataColumn(label: Text('Job Title'))", "DataColumn(label: Text(AppLocalizations.of(context)!.jobTitle))"),
        ("const DataColumn(label: Text('Current Salary'))", "DataColumn(label: Text(AppLocalizations.of(context)!.currentSalary))"),
        ("Text('Error: $e')", "Text('${AppLocalizations.of(context)!.error}: $e')"),
    ],
    'lib/features/areas/area_screen.dart': [
        ("const Text('Add New Area')", "Text(AppLocalizations.of(context)!.addArea)"),
        ("const InputDecoration(labelText: 'Area Name')", "InputDecoration(labelText: AppLocalizations.of(context)!.areaName)"),
        ("const InputDecoration(labelText: 'City')", "InputDecoration(labelText: AppLocalizations.of(context)!.city)"),
        ("const Text('Cancel')", "Text(AppLocalizations.of(context)!.cancel)"),
        ("const Text('Save Area')", "Text(AppLocalizations.of(context)!.saveArea)"),
        ("Text('Area Management'", "Text(AppLocalizations.of(context)!.areaManagement"),
        ("const Text('No areas found.')", "Text(AppLocalizations.of(context)!.noAreas)"),
        ("const DataColumn(label: Text('Area Name'))", "DataColumn(label: Text(AppLocalizations.of(context)!.areaName))"),
        ("const DataColumn(label: Text('City'))", "DataColumn(label: Text(AppLocalizations.of(context)!.city))"),
        ("Text('Error: $e')", "Text('${AppLocalizations.of(context)!.error}: $e')"),
    ],
    'lib/features/ledger/khata_ledger_screen.dart': [
        ("Text('Khata Ledger'", "Text(AppLocalizations.of(context)!.khataLedger"),
        ("const Text('Customers')", "Text(AppLocalizations.of(context)!.customers)"),
        ("const Text('Suppliers')", "Text(AppLocalizations.of(context)!.suppliers)"),
        ("Text('Add Customer')", "Text(AppLocalizations.of(context)!.addCustomer)"),
        ("Text('Add Supplier')", "Text(AppLocalizations.of(context)!.addSupplier)"),
        ("Text('Add $selectedType')", "Text(selectedType == 'Customer' ? AppLocalizations.of(context)!.addCustomer : AppLocalizations.of(context)!.addSupplier)"),
        ("const InputDecoration(labelText: 'Account Name')", "InputDecoration(labelText: AppLocalizations.of(context)!.accountName)"),
        ("const InputDecoration(labelText: 'Credit Limit')", "InputDecoration(labelText: AppLocalizations.of(context)!.creditLimit)"),
        ("const Text('Select Area (Optional)')", "Text(AppLocalizations.of(context)!.selectArea)"),
        ("const Text('Cancel')", "Text(AppLocalizations.of(context)!.cancel)"),
        ("const Text('Save')", "Text(AppLocalizations.of(context)!.save)"),
        ("Text('No Customer accounts found.')", "Text(AppLocalizations.of(context)!.noAccountsFound)"),
        ("Text('No Supplier accounts found.')", "Text(AppLocalizations.of(context)!.noAccountsFound)"),
        ("Text('No $selectedType accounts found.')", "Text(AppLocalizations.of(context)!.noAccountsFound)"),
        ("const Text('View Ledger')", "Text(AppLocalizations.of(context)!.viewLedger)"),
        ("Text('Error: $e')", "Text('${AppLocalizations.of(context)!.error}: $e')"),
    ],
    'lib/features/purchases/grn_screen.dart': [
        ("Text('Record Goods Receipt Note (GRN)'", "Text(AppLocalizations.of(context)!.recordGrn"),
        ("const Text('Select Supplier')", "Text(AppLocalizations.of(context)!.selectSupplier)"),
        ("const Text('Select Part')", "Text(AppLocalizations.of(context)!.selectPart)"),
        ("const InputDecoration(labelText: 'Quantity')", "InputDecoration(labelText: AppLocalizations.of(context)!.quantity)"),
        ("const InputDecoration(labelText: 'Unit Price')", "InputDecoration(labelText: AppLocalizations.of(context)!.unitPrice)"),
        ("const Text('Add Item')", "Text(AppLocalizations.of(context)!.addItem)"),
        ("const Text('No items added.')", "Text(AppLocalizations.of(context)!.noItemsGrn)"),
        ("const Text('Save GRN')", "Text(AppLocalizations.of(context)!.saveGrn)"),
        ("const Text('Item/Part')", "Text(AppLocalizations.of(context)!.itemPart)"),
        ("const Text('Qty')", "Text(AppLocalizations.of(context)!.quantityPos)"),
        ("const Text('Price')", "Text(AppLocalizations.of(context)!.price)"),
        ("const Text('Total')", "Text(AppLocalizations.of(context)!.total)"),
    ],
    'lib/features/returns/returns_claims_screen.dart': [
        ("Text('Returns & Claims'", "Text(AppLocalizations.of(context)!.returnsClaims"),
        ("const InputDecoration(labelText: 'Select Original Invoice')", "InputDecoration(labelText: AppLocalizations.of(context)!.selectInvoice)"),
        ("const InputDecoration(labelText: 'Refund Method')", "InputDecoration(labelText: AppLocalizations.of(context)!.selectMethod)"),
        ("const Text('Cash')", "Text(AppLocalizations.of(context)!.cash)"),
        ("const Text('Khata Credit')", "Text(AppLocalizations.of(context)!.khataCredit)"),
        ("const Text('Approve & Process Return')", "Text(AppLocalizations.of(context)!.approveReturn)"),
        ("const Text('Return Processed (Mock)')", "Text(AppLocalizations.of(context)!.processReturnMock)"),
    ]
}

for file_path, replacements in files_to_update.items():
    if not os.path.exists(file_path):
        print(f"Skipping {file_path}")
        continue
    with open(file_path, 'r', encoding='utf-8') as f:
        content = f.read()
        
    # Inject import
    if "app_localizations.dart" not in content:
        content = content.replace(
            "import 'package:flutter/material.dart';", 
            "import 'package:flutter/material.dart';\nimport '../../core/localization/l10n/app_localizations.dart';"
        )
        
    # Remove any stray 'const ' before Text or InputDecoration if we are replacing it with a variable
    # We did this mostly manually in the tuples, but let's be careful.
    for old_str, new_str in replacements:
        content = content.replace(old_str, new_str)
        # Also handle cases where `const` is outside
        # e.g. `const [ DataColumn(label: Text('Type')) ]` -> if we replaced Text, the const array might break.
        # So we just do a quick fix for `const [` if it breaks compilation, but we'll try to just remove `const` from specific lines.
        
    # Replace `const [` with `[` around DataColumns
    content = content.replace("columns: const [", "columns: [")
    content = content.replace("segments: const [", "segments: [")
    
    with open(file_path, 'w', encoding='utf-8') as f:
        f.write(content)
        
print("Updated dart files.")
