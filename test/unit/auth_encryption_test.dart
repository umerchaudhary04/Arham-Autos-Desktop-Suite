import 'package:flutter_test/flutter_test.dart';
import 'package:arham_autos/core/security/encryption_key_store.dart';
import 'package:arham_autos/core/security/idle_lock_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  test('DPAPI encryption key retrieval and fallback using test double', () async {
    final keyStore = InMemoryKeyStore();
    
    // Initial state: no key
    final initialKey = await keyStore.loadKey();
    expect(initialKey, isNull);
    
    // Save key
    await keyStore.saveKey('my-secret-key');
    
    // Retrieve key
    final loadedKey = await keyStore.loadKey();
    expect(loadedKey, 'my-secret-key');
    
    // Generate recovery key format
    final recovery = keyStore.generateRecoveryKey();
    expect(recovery.split('-').length, 6);
  });

  test('Idle auto-lock timeout mechanism', () {
    final container = ProviderContainer();
    
    // Initial default is usually 15 or 30 minutes in seconds (900/1800), check state
    final initialTimeout = container.read(idleLockProvider);
    expect(initialTimeout, isA<int>());
    
    // Update timeout
    container.read(idleLockProvider.notifier).updateTimeout(300); // 5 minutes
    final updatedTimeout = container.read(idleLockProvider);
    expect(updatedTimeout, 300);
  });
}
