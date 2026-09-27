import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ur.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ur'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Arham Autos Desktop Suite'**
  String get appTitle;

  /// No description provided for @navDashboard.
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get navDashboard;

  /// No description provided for @navPosBilling.
  ///
  /// In en, this message translates to:
  /// **'POS Billing'**
  String get navPosBilling;

  /// No description provided for @navPartsCatalog.
  ///
  /// In en, this message translates to:
  /// **'Parts Catalog'**
  String get navPartsCatalog;

  /// No description provided for @navKhataLedger.
  ///
  /// In en, this message translates to:
  /// **'Khata Ledger'**
  String get navKhataLedger;

  /// No description provided for @navGrn.
  ///
  /// In en, this message translates to:
  /// **'Purchases / GRN'**
  String get navGrn;

  /// No description provided for @navReturns.
  ///
  /// In en, this message translates to:
  /// **'Returns & Claims'**
  String get navReturns;

  /// No description provided for @navAccounts.
  ///
  /// In en, this message translates to:
  /// **'Accounts & Expenses'**
  String get navAccounts;

  /// No description provided for @navEmployees.
  ///
  /// In en, this message translates to:
  /// **'Employees'**
  String get navEmployees;

  /// No description provided for @navAreas.
  ///
  /// In en, this message translates to:
  /// **'Areas'**
  String get navAreas;

  /// No description provided for @navReports.
  ///
  /// In en, this message translates to:
  /// **'Reports'**
  String get navReports;

  /// No description provided for @navBackup.
  ///
  /// In en, this message translates to:
  /// **'Backup & Restore'**
  String get navBackup;

  /// No description provided for @navSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get navSettings;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Admin Settings'**
  String get settingsTitle;

  /// No description provided for @languageToggle.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get languageToggle;

  /// No description provided for @securityConfig.
  ///
  /// In en, this message translates to:
  /// **'Security Configuration'**
  String get securityConfig;

  /// No description provided for @idleTimeout.
  ///
  /// In en, this message translates to:
  /// **'Idle Auto-Lock Timeout (minutes):'**
  String get idleTimeout;

  /// No description provided for @userManagement.
  ///
  /// In en, this message translates to:
  /// **'User Management'**
  String get userManagement;

  /// No description provided for @addUser.
  ///
  /// In en, this message translates to:
  /// **'Add User'**
  String get addUser;

  /// No description provided for @editUser.
  ///
  /// In en, this message translates to:
  /// **'Edit User'**
  String get editUser;

  /// No description provided for @deleteUser.
  ///
  /// In en, this message translates to:
  /// **'Delete User'**
  String get deleteUser;

  /// No description provided for @deleteUserConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this user?'**
  String get deleteUserConfirm;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @username.
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get username;

  /// No description provided for @fullName.
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get fullName;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @pin.
  ///
  /// In en, this message translates to:
  /// **'PIN (4 digits)'**
  String get pin;

  /// No description provided for @role.
  ///
  /// In en, this message translates to:
  /// **'Role'**
  String get role;

  /// No description provided for @viewAuditLog.
  ///
  /// In en, this message translates to:
  /// **'View System Audit Log'**
  String get viewAuditLog;

  /// No description provided for @addNewPart.
  ///
  /// In en, this message translates to:
  /// **'Add New Part'**
  String get addNewPart;

  /// No description provided for @partName.
  ///
  /// In en, this message translates to:
  /// **'Part Name *'**
  String get partName;

  /// No description provided for @oemNumber.
  ///
  /// In en, this message translates to:
  /// **'OEM Number'**
  String get oemNumber;

  /// No description provided for @model.
  ///
  /// In en, this message translates to:
  /// **'Model'**
  String get model;

  /// No description provided for @rackLocation.
  ///
  /// In en, this message translates to:
  /// **'Rack Location'**
  String get rackLocation;

  /// No description provided for @minReorderLevel.
  ///
  /// In en, this message translates to:
  /// **'Min Reorder Level'**
  String get minReorderLevel;

  /// No description provided for @savePart.
  ///
  /// In en, this message translates to:
  /// **'Save Part'**
  String get savePart;

  /// No description provided for @partsCatalogTitle.
  ///
  /// In en, this message translates to:
  /// **'Parts Catalog & Inventory'**
  String get partsCatalogTitle;

  /// No description provided for @searchParts.
  ///
  /// In en, this message translates to:
  /// **'Search by Part Name, OEM #, Model, or Rack'**
  String get searchParts;

  /// No description provided for @noPartsFound.
  ///
  /// In en, this message translates to:
  /// **'No parts found.'**
  String get noPartsFound;

  /// No description provided for @adjustStock.
  ///
  /// In en, this message translates to:
  /// **'Adjust Stock'**
  String get adjustStock;

  /// No description provided for @authorizedMock.
  ///
  /// In en, this message translates to:
  /// **'Authorized. (Structural Mock)'**
  String get authorizedMock;

  /// No description provided for @khataLedger.
  ///
  /// In en, this message translates to:
  /// **'Khata Ledger'**
  String get khataLedger;

  /// No description provided for @customers.
  ///
  /// In en, this message translates to:
  /// **'Customers'**
  String get customers;

  /// No description provided for @suppliers.
  ///
  /// In en, this message translates to:
  /// **'Suppliers'**
  String get suppliers;

  /// No description provided for @addCustomer.
  ///
  /// In en, this message translates to:
  /// **'Add Customer'**
  String get addCustomer;

  /// No description provided for @addSupplier.
  ///
  /// In en, this message translates to:
  /// **'Add Supplier'**
  String get addSupplier;

  /// No description provided for @accountName.
  ///
  /// In en, this message translates to:
  /// **'Account Name'**
  String get accountName;

  /// No description provided for @creditLimit.
  ///
  /// In en, this message translates to:
  /// **'Credit Limit'**
  String get creditLimit;

  /// No description provided for @selectArea.
  ///
  /// In en, this message translates to:
  /// **'Select Area (Optional)'**
  String get selectArea;

  /// No description provided for @viewLedger.
  ///
  /// In en, this message translates to:
  /// **'View Ledger'**
  String get viewLedger;

  /// No description provided for @noAccountsFound.
  ///
  /// In en, this message translates to:
  /// **'No accounts found.'**
  String get noAccountsFound;

  /// No description provided for @balance.
  ///
  /// In en, this message translates to:
  /// **'Balance'**
  String get balance;

  /// No description provided for @limit.
  ///
  /// In en, this message translates to:
  /// **'Limit'**
  String get limit;

  /// No description provided for @recordGrn.
  ///
  /// In en, this message translates to:
  /// **'Record Goods Receipt Note (GRN)'**
  String get recordGrn;

  /// No description provided for @selectSupplier.
  ///
  /// In en, this message translates to:
  /// **'Select Supplier'**
  String get selectSupplier;

  /// No description provided for @selectPart.
  ///
  /// In en, this message translates to:
  /// **'Select Part'**
  String get selectPart;

  /// No description provided for @quantity.
  ///
  /// In en, this message translates to:
  /// **'Quantity'**
  String get quantity;

  /// No description provided for @unitPrice.
  ///
  /// In en, this message translates to:
  /// **'Unit Price'**
  String get unitPrice;

  /// No description provided for @addItem.
  ///
  /// In en, this message translates to:
  /// **'Add Item'**
  String get addItem;

  /// No description provided for @noItemsGrn.
  ///
  /// In en, this message translates to:
  /// **'No items added.'**
  String get noItemsGrn;

  /// No description provided for @saveGrn.
  ///
  /// In en, this message translates to:
  /// **'Save GRN'**
  String get saveGrn;

  /// No description provided for @itemPart.
  ///
  /// In en, this message translates to:
  /// **'Item/Part'**
  String get itemPart;

  /// No description provided for @total.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get total;

  /// No description provided for @price.
  ///
  /// In en, this message translates to:
  /// **'Price'**
  String get price;

  /// No description provided for @posBilling.
  ///
  /// In en, this message translates to:
  /// **'POS Billing'**
  String get posBilling;

  /// No description provided for @searchPartToAdd.
  ///
  /// In en, this message translates to:
  /// **'Search part to add...'**
  String get searchPartToAdd;

  /// No description provided for @quantityPos.
  ///
  /// In en, this message translates to:
  /// **'Qty'**
  String get quantityPos;

  /// No description provided for @pricePos.
  ///
  /// In en, this message translates to:
  /// **'Price (Rs)'**
  String get pricePos;

  /// No description provided for @parkSale.
  ///
  /// In en, this message translates to:
  /// **'Park Sale'**
  String get parkSale;

  /// No description provided for @recallSale.
  ///
  /// In en, this message translates to:
  /// **'Recall Sale'**
  String get recallSale;

  /// No description provided for @checkout.
  ///
  /// In en, this message translates to:
  /// **'Checkout'**
  String get checkout;

  /// No description provided for @noItemsPos.
  ///
  /// In en, this message translates to:
  /// **'No items in cart.'**
  String get noItemsPos;

  /// No description provided for @returnsClaims.
  ///
  /// In en, this message translates to:
  /// **'Returns & Claims'**
  String get returnsClaims;

  /// No description provided for @selectInvoice.
  ///
  /// In en, this message translates to:
  /// **'Select Original Invoice'**
  String get selectInvoice;

  /// No description provided for @selectMethod.
  ///
  /// In en, this message translates to:
  /// **'Refund Method'**
  String get selectMethod;

  /// No description provided for @cash.
  ///
  /// In en, this message translates to:
  /// **'Cash'**
  String get cash;

  /// No description provided for @khataCredit.
  ///
  /// In en, this message translates to:
  /// **'Khata Credit'**
  String get khataCredit;

  /// No description provided for @approveReturn.
  ///
  /// In en, this message translates to:
  /// **'Approve & Process Return'**
  String get approveReturn;

  /// No description provided for @processReturnMock.
  ///
  /// In en, this message translates to:
  /// **'Return Processed (Mock)'**
  String get processReturnMock;

  /// No description provided for @accountsExpenses.
  ///
  /// In en, this message translates to:
  /// **'Accounts & Expenses'**
  String get accountsExpenses;

  /// No description provided for @addAccount.
  ///
  /// In en, this message translates to:
  /// **'Add Account'**
  String get addAccount;

  /// No description provided for @recordTransaction.
  ///
  /// In en, this message translates to:
  /// **'Record Transaction'**
  String get recordTransaction;

  /// No description provided for @type.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get type;

  /// No description provided for @description.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get description;

  /// No description provided for @amount.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get amount;

  /// No description provided for @noAccounts.
  ///
  /// In en, this message translates to:
  /// **'No accounts found.'**
  String get noAccounts;

  /// No description provided for @employeeManagement.
  ///
  /// In en, this message translates to:
  /// **'Employee Management'**
  String get employeeManagement;

  /// No description provided for @addEmployee.
  ///
  /// In en, this message translates to:
  /// **'Add Employee'**
  String get addEmployee;

  /// No description provided for @jobTitle.
  ///
  /// In en, this message translates to:
  /// **'Job Title'**
  String get jobTitle;

  /// No description provided for @currentSalary.
  ///
  /// In en, this message translates to:
  /// **'Current Salary'**
  String get currentSalary;

  /// No description provided for @saveEmployee.
  ///
  /// In en, this message translates to:
  /// **'Save Employee'**
  String get saveEmployee;

  /// No description provided for @noEmployees.
  ///
  /// In en, this message translates to:
  /// **'No employees found.'**
  String get noEmployees;

  /// No description provided for @areaManagement.
  ///
  /// In en, this message translates to:
  /// **'Area Management'**
  String get areaManagement;

  /// No description provided for @addArea.
  ///
  /// In en, this message translates to:
  /// **'Add New Area'**
  String get addArea;

  /// No description provided for @areaName.
  ///
  /// In en, this message translates to:
  /// **'Area Name'**
  String get areaName;

  /// No description provided for @city.
  ///
  /// In en, this message translates to:
  /// **'City'**
  String get city;

  /// No description provided for @saveArea.
  ///
  /// In en, this message translates to:
  /// **'Save Area'**
  String get saveArea;

  /// No description provided for @noAreas.
  ///
  /// In en, this message translates to:
  /// **'No areas found.'**
  String get noAreas;

  /// No description provided for @reportsTitle.
  ///
  /// In en, this message translates to:
  /// **'Reports & Analytics'**
  String get reportsTitle;

  /// No description provided for @dailySales.
  ///
  /// In en, this message translates to:
  /// **'Daily Sales Report'**
  String get dailySales;

  /// No description provided for @inventoryValuation.
  ///
  /// In en, this message translates to:
  /// **'Inventory Valuation'**
  String get inventoryValuation;

  /// No description provided for @customerBalances.
  ///
  /// In en, this message translates to:
  /// **'Customer Balances'**
  String get customerBalances;

  /// No description provided for @exportData.
  ///
  /// In en, this message translates to:
  /// **'Export Data to CSV'**
  String get exportData;

  /// No description provided for @backupRestore.
  ///
  /// In en, this message translates to:
  /// **'Backup & Restore'**
  String get backupRestore;

  /// No description provided for @createBackup.
  ///
  /// In en, this message translates to:
  /// **'Create Backup'**
  String get createBackup;

  /// No description provided for @restoreBackup.
  ///
  /// In en, this message translates to:
  /// **'Restore Backup'**
  String get restoreBackup;

  /// No description provided for @selectFile.
  ///
  /// In en, this message translates to:
  /// **'Select Backup File'**
  String get selectFile;

  /// No description provided for @restore.
  ///
  /// In en, this message translates to:
  /// **'Restore'**
  String get restore;

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'ur'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ur':
      return AppLocalizationsUr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
