# Arham Autos Desktop Suite

Arham Autos Desktop Suite is an enterprise-grade, fully offline, high-performance Windows desktop application built for auto parts retailers, wholesalers, and spare parts distributors. It streamlines point-of-sale (POS) billing, FIFO inventory management, supplier goods receipt notes (GRN), customer & supplier Khata (ledgers), sales returns, General Ledger (GL) accounting, HR & payroll, and multi-tier role-based access control.

Designed for speed, data privacy, and zero downtime, the application runs entirely locally on Windows without requiring an active internet connection. It is engineered with SQLCipher AES-256 database encryption, Windows DPAPI key security, keyboard-first workflows, and seamless bilingual support (English and Urdu Nastaliq RTL).

---

## Key Features

*   **Offline-First & Encrypted Storage:** Data is stored locally using SQLite in WAL mode with SQLCipher AES-256 encryption. Encryption keys are securely bound to the Windows user account via Windows DPAPI (Credential Manager) with BitLocker-style recovery key fallback.
*   **Keyboard-Wedge Barcode & POS Billing:** High-speed POS billing built for 100% keyboard-first navigation (Tab, Enter, Function keys) combined with barcode scanner support, instant cart calculations, parked carts, and split cash/credit settlements.
*   **FIFO Inventory Engine & Real-Time Search:** Automatic Cost of Goods Sold (COGS) tracking utilizing strict First-In-First-Out batch allocation. Includes debounced real-time catalog search across thousands of SKUs, category/brand filters, and low-stock alerts.
*   **Purchases & Goods Receipt Notes (GRN):** Structured receiving workflow for supplier shipments, automatic inventory lot creation with cost tracking, landed cost adjustments, and direct supplier ledger crediting.
*   **Customer & Supplier Khata Ledgers:** Double-sided ledger management supporting credit sales, supplier payables, partial receipts, debit/credit adjustments, and printable PDF statements.
*   **Returns & Claims Management:** Dedicated handling for customer sales returns and supplier warranty/defective returns with automatic stock batch re-integration and ledger reconciliations.
*   **General Ledger (GL) & Expense Tracking:** Chart of Accounts, operational expense logging, cash and bank transaction registers, and financial activity tracking.
*   **HR & Employee Management:** Staff records, salary advances, monthly payroll generation, and disbursement tracking.
*   **Geographic Area & Route Management:** Territory tagging for customers and suppliers to streamline delivery routing and payment recovery operations.
*   **Silent Thermal & A4 Printing:** Invoices and receipts are dynamically generated as PDF documents and printed silently to default thermal (80mm/58mm) or standard A4 printers without disruptive OS print dialogs.
*   **Reporting & Analytics:** Interactive dashboard and dedicated reports for sales performance, profit & loss, inventory valuation, daily register reconciliation, and system audit logs with one-click Excel, CSV, and PDF exports.
*   **Role-Based Access Control (RBAC):** Three strict authorization tiers:
    *   **Admin:** Complete system configuration, user account management (create/edit/delete), security policies, idle lock timeout, area management, database backup/restore, and audit logs.
    *   **Manager:** Inventory catalog, stock adjustments, GRN purchases, returns approvals, GL & expenses, HR payroll, and analytical reports.
    *   **Operator:** Dedicated to rapid POS billing, customer lookups, parked carts, and receipt generation.
*   **Bilingual Localization (English & Urdu):** Complete localization in English and Urdu (Nastaliq script) with dynamic Right-to-Left (RTL) layout mirroring without requiring an application restart.
*   **Automated Backup & Integrity Checks:** Integrated database backup engine generating encrypted backup files verified through SQLite `PRAGMA integrity_check` before restore.

---

## Technology Stack

*   **Framework:** [Flutter](https://flutter.dev/) (Windows Desktop Target)
*   **Language:** [Dart](https://dart.dev/) (^3.11.4)
*   **State Management:** [Riverpod](https://riverpod.dev/) (`flutter_riverpod`, `riverpod_annotation`, `riverpod_generator`)
*   **Local Database & ORM:** [Drift](https://drift.simonbinder.eu/) (SQLite in WAL mode)
*   **Database Encryption:** `sqlcipher_flutter_libs` (AES-256)
*   **Security & Credentials:** `flutter_secure_storage` (Windows DPAPI / Credential Manager)
*   **PDF Generation & Silent Printing:** `pdf` and `printing`
*   **Data Export:** `excel` and `csv`
*   **Window Management:** `window_manager`
*   **Localization & Internationalization:** `flutter_localizations` & `intl`

---

## System Architecture & Project Structure

```text
lib/
├── core/
│   ├── db/                 # Drift database schema, DAOs (ledger, parts, pos, reports, users)
│   ├── localization/       # ARB localization files (en, ur) & generated delegates
│   └── security/           # Auth provider, DPAPI key store, idle lock, PIN pad
├── features/
│   ├── admin/              # User management, settings, login screen, shell layout, audit logs
│   ├── areas/              # Geographic routing & territory management
│   ├── backup/             # Database backup & restore engine with integrity check
│   ├── gl/                 # General Ledger, Chart of Accounts & expense tracking
│   ├── hr/                 # Employee management & payroll processing
│   ├── ledger/             # Customer & supplier Khata ledger screens
│   ├── parts/              # Inventory catalog with debounced search & stock alerts
│   ├── pos/                # POS billing screen, cart provider, thermal receipt print service
│   ├── purchases/          # Goods Receipt Notes (GRN) & batch receiving
│   ├── reports/            # Dashboard analytics, reports screen, and Excel/CSV/PDF export
│   └── returns/            # Sales & purchase returns and claims service
└── main.dart               # App initialization, window configuration & theme bootstrap
```

---

## Getting Started

### Prerequisites

*   **Operating System:** Windows 10 or Windows 11 (64-bit)
*   **Flutter SDK:** Version 3.11.4 or higher
*   **Visual Studio 2022:** With the **Desktop development with C++** workload installed
*   **Inno Setup 6:** (Optional) Required only if compiling the Windows installer package

### Development Setup

1.  **Clone the Repository:**
    ```cmd
    git clone https://github.com/umerchaudhary04/Arham-Autos.git
    cd Arham-Autos
    ```

2.  **Install Dependencies:**
    ```cmd
    flutter pub get
    ```

3.  **Generate Code (Riverpod & Drift):**
    ```cmd
    flutter pub run build_runner build --delete-conflicting-outputs
    ```

4.  **Run the App (Debug Mode):**
    ```cmd
    flutter run -d windows
    ```

---

## Running Tests

The test suite covers unit logic, database migrations, security, and integration flows:

```cmd
# Run all tests
flutter test

# Run unit tests (FIFO engine, Auth/DPAPI, Data models, GL & HR)
flutter test test/unit/

# Run integration tests (POS billing, GRN, Returns)
flutter test test/integration/

# Run system & stress tests
flutter test test/system/
flutter test test/stress_test.dart
```

---

## Building for Production

### 1. Compile the Release Executable

Generate the optimized 64-bit release build:
```cmd
flutter build windows
```
The output binaries will be created in:
```text
build\windows\x64\runner\Release\
```

### 2. Package with Inno Setup (Windows Installer)

An Inno Setup script is provided at `windows/installer/arham_autos.iss`. It bundles the Flutter release binaries, creates desktop/start-menu shortcuts, and configures permissions for the application data folder.

To compile using the Inno Setup CLI (`ISCC.exe`):
```cmd
"C:\Program Files (x86)\Inno Setup 6\ISCC.exe" windows\installer\arham_autos.iss
```
The standalone installer executable will be generated at:
```text
build\windows\installer\ArhamAutosSetup.exe
```

### Application Data Directory

In production, persistent application data (encrypted database, logs, and backups) is stored in the current user's roaming directory:
```text
%APPDATA%\ArhamAutos\
```

---

## Security & Maintenance Notes

*   **DPAPI Key Protection:** The encryption key is tied to the active Windows User Account via Windows DPAPI. Changing the Windows account or migrating files to another machine requires entering the master recovery key generated during first-time setup.
*   **Data Integrity:** Always verify database backups before performing a system restore. The built-in restore utility automatically runs `PRAGMA integrity_check` before applying restored databases.
*   **Audit Logging:** Critical business operations (price adjustments, user modifications, manual stock edits, voids) are permanently recorded in the system audit log.

---

**Developer:** Umer Asghar | Flutter Developer
