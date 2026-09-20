import 'package:flutter_test/flutter_test.dart';
import 'dart:convert';

// Simplified representation of the JSON payload for parked_carts
void main() {
  test('JSON serialization/deserialization for parked_carts', () {
    final cartItems = [
      {'partId': 'part_1', 'quantity': 5, 'unitPrice': 150.0},
      {'partId': 'part_2', 'quantity': 2, 'unitPrice': 50.0},
    ];
    
    final payload = {
      'items': cartItems,
      'discount': 10.0,
      'customerId': 'cust_123'
    };
    
    // Serialize
    final jsonString = jsonEncode(payload);
    expect(jsonString, isA<String>());
    
    // Deserialize
    final decoded = jsonDecode(jsonString) as Map<String, dynamic>;
    expect(decoded['discount'], 10.0);
    expect(decoded['customerId'], 'cust_123');
    
    final itemsList = decoded['items'] as List<dynamic>;
    expect(itemsList.length, 2);
    expect(itemsList[0]['partId'], 'part_1');
    expect(itemsList[0]['quantity'], 5);
  });
}
