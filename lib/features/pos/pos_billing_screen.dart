import 'package:flutter/material.dart';
import '../../core/localization/l10n/app_localizations.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'pos_provider.dart';
import '../../core/security/admin_pin_modal.dart';
import '../../core/db/database.dart';
import 'package:drift/drift.dart' hide Column;
import '../../core/security/auth_provider.dart';

class PosBillingScreen extends ConsumerStatefulWidget {
  const PosBillingScreen({super.key});

  @override
  ConsumerState<PosBillingScreen> createState() => _PosBillingScreenState();
}

class _PosBillingScreenState extends ConsumerState<PosBillingScreen> {
  final _searchFocusNode = FocusNode();
  final _searchController = TextEditingController();

  DateTime? _lastKeystrokeTime;
  String _barcodeBuffer = '';
  
  List<AutoPart> _searchResults = [];
  int _selectedResultIndex = 0;
  bool _isLoadingSearch = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _searchFocusNode.requestFocus();
    });
    
    _searchController.addListener(_onSearchChanged);
  }
  
  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _onSearchChanged() async {
    final query = _searchController.text;
    if (query.isEmpty) {
      if (mounted) {
        setState(() {
          _searchResults = [];
          _selectedResultIndex = 0;
        });
      }
      return;
    }
    
    final db = ref.read(databaseProvider);
    if (db == null) return;
    
    setState(() { _isLoadingSearch = true; });
    final parts = await db.partsDao.searchParts(query);
    if (mounted) {
      setState(() {
        _searchResults = parts;
        _selectedResultIndex = 0;
        _isLoadingSearch = false;
      });
    }
  }

  void _onKey(KeyEvent event) {
    if (event is KeyDownEvent) {
      if (event.logicalKey == LogicalKeyboardKey.f12) {
        _checkout();
        return;
      } else if (event.logicalKey == LogicalKeyboardKey.f10) {
        _overridePrice();
        return;
      } else if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
        if (_searchResults.isNotEmpty && _selectedResultIndex < _searchResults.length - 1) {
          setState(() { _selectedResultIndex++; });
        }
        return;
      } else if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
        if (_searchResults.isNotEmpty && _selectedResultIndex > 0) {
          setState(() { _selectedResultIndex--; });
        }
        return;
      } else if (event.logicalKey == LogicalKeyboardKey.enter) {
         if (_searchResults.isNotEmpty) {
           _selectPart(_searchResults[_selectedResultIndex]);
           return;
         } else if (_searchController.text.isNotEmpty && _searchResults.isEmpty && !_isLoadingSearch) {
           if (mounted) {
             ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Item Not Found')));
           }
           return;
         }
      }

      // Barcode Wedge Detection: rapid keystrokes (< 50ms between keys)
      final now = DateTime.now();
      if (_lastKeystrokeTime != null &&
          now.difference(_lastKeystrokeTime!).inMilliseconds < 50) {
        if (event.character != null) {
          _barcodeBuffer += event.character!;
        } else if (event.logicalKey == LogicalKeyboardKey.enter) {
          if (_barcodeBuffer.isNotEmpty) {
            _searchController.text = _barcodeBuffer;
            _barcodeBuffer = '';
          }
        }
      } else {
        if (event.character != null) {
          _barcodeBuffer = event.character!;
        }
      }
      _lastKeystrokeTime = now;
    }
  }

  void _selectPart(AutoPart part) async {
    final qtyCtrl = TextEditingController(text: '');
    final priceCtrl = TextEditingController(text: '');
    
    final db = ref.read(databaseProvider);
    if (db == null) return;
    
    // Check if we can find a recent selling price for this part
    final recentItem = await (db.select(db.invoiceItems)..where((t) => t.partId.equals(part.partId))..orderBy([(t) => OrderingTerm(expression: t.itemId, mode: OrderingMode.desc)])..limit(1)).getSingleOrNull();
    if (recentItem != null) {
      priceCtrl.text = recentItem.unitPrice.toString();
    }
    
    // Check stock level to prevent over-selling
    final stockLevel = await db.partsDao.getStockLevel(part.partId);
    if (stockLevel <= 0) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Out of Stock: \${part.partName}')));
      return;
    }

    if (!mounted) return;
    
    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Add \${part.partName}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Available Stock: $stockLevel'),
            const SizedBox(height: 16),
            TextField(
              controller: qtyCtrl,
              keyboardType: TextInputType.number,
              autofocus: true,
              decoration: const InputDecoration(labelText: 'Quantity'),
              onSubmitted: (_) {
                // Submit logic or focus next
              },
            ),
            const SizedBox(height: 16),
            TextField(
              controller: priceCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Selling Price (Rs)'),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
               final qty = int.tryParse(qtyCtrl.text) ?? 0;
               final price = double.tryParse(priceCtrl.text) ?? 0.0;
               if (qty > 0 && qty <= stockLevel && price >= 0) {
                 ref.read(posCartProvider.notifier).addItem(part.partId, qty, price, partName: part.partName);
                 Navigator.pop(ctx);
                 _searchController.clear();
                 _searchFocusNode.requestFocus();
               } else if (qty > stockLevel) {
                 ScaffoldMessenger.of(ctx).showSnackBar(const SnackBar(content: Text('Quantity exceeds available stock')));
               }
            },
            child: const Text('Add to Bill'),
          ),
        ],
      ),
    );
  }

  void _overridePrice() async {
    final auth = await AdminPinModal.show(
      context,
      'Override Unit Price or Discount',
    );
    if (auth) {
      final discountCtrl = TextEditingController();
      if (!mounted) return;
      await showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Enter Discount Amount'),
          content: TextField(
            controller: discountCtrl,
            keyboardType: TextInputType.number,
            autofocus: true,
            decoration: const InputDecoration(labelText: 'Discount (Rs)'),
            onSubmitted: (val) {
               final d = double.tryParse(val) ?? 0.0;
               ref.read(posCartProvider.notifier).setDiscount(d);
               Navigator.pop(ctx);
            },
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () {
                 final d = double.tryParse(discountCtrl.text) ?? 0.0;
                 ref.read(posCartProvider.notifier).setDiscount(d);
                 Navigator.pop(ctx);
              },
              child: const Text('Apply'),
            ),
          ],
        ),
      );
      _searchFocusNode.requestFocus();
    }
  }

  void _checkout() async {
    try {
      final success = await ref.read(posCartProvider.notifier).checkout();
      if (success) {
        if (mounted)
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Checkout Complete. Printing...')),
          );
      } else {
        if (mounted)
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Checkout Failed.')));
      }
    } catch (e) {
      if (mounted) {
         ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Checkout Error: $e')));
      }
    }
    _searchFocusNode.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    final cartState = ref.watch(posCartProvider);

    return KeyboardListener(
      focusNode: FocusNode(),
      onKeyEvent: _onKey,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'POS Billing',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 16),

            // Search / Scan Input
            TextField(
              controller: _searchController,
              focusNode: _searchFocusNode,
              decoration: const InputDecoration(
                labelText: 'Scan Barcode or Search Part Name / OEM #',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.search),
              ),
            ),

            // Search Results
            if (_searchResults.isNotEmpty)
              Container(
                constraints: const BoxConstraints(maxHeight: 200),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  color: Colors.white,
                ),
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: _searchResults.length,
                  itemBuilder: (context, index) {
                    final part = _searchResults[index];
                    final isSelected = index == _selectedResultIndex;
                    return Container(
                      color: isSelected ? Colors.blue.shade50 : null,
                      child: ListTile(
                        title: Text(part.partName),
                        subtitle: Text(part.oemNumber ?? ''),
                        onTap: () => _selectPart(part),
                        trailing: isSelected ? const Icon(Icons.keyboard_return, size: 16) : null,
                      ),
                    );
                  },
                ),
              ),

            const SizedBox(height: 16),

            // Cart Items List
            Expanded(
              child: ListView.builder(
                itemCount: cartState.items.length,
                itemBuilder: (context, index) {
                  final item = cartState.items[index];
                  return ListTile(
                    title: Text(item.partName ?? item.partId),
                    subtitle: Text(
                      'Qty: ${item.quantity} x Rs ${item.unitPrice}',
                    ),
                    trailing: Text('Rs ${item.quantity * item.unitPrice}'),
                  );
                },
              ),
            ),

            // Totals and Actions
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Subtotal: Rs ${cartState.subtotal}',
                  style: const TextStyle(fontSize: 18),
                ),
                Text(
                  'Discount: Rs ${cartState.discount}',
                  style: const TextStyle(fontSize: 18, color: Colors.red),
                ),
                Text(
                  'Total: Rs ${cartState.total}',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton.icon(
                  onPressed: _overridePrice,
                  icon: const Icon(Icons.discount),
                  label: const Text('Discount (F10)'),
                ),
                const SizedBox(width: 16),
                ElevatedButton.icon(
                  onPressed: _checkout,
                  icon: const Icon(Icons.payment),
                  label: const Text('Checkout (F12)'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
