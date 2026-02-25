import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:consumer/providers.dart';

void main() {
  group('CartNotifier', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    test('starts empty', () {
      final cart = container.read(cartProvider);
      expect(cart, isEmpty);
    });

    test('add item increases quantity', () {
      final notifier = container.read(cartProvider.notifier);
      notifier.add('part-123');
      expect(container.read(cartProvider), {'part-123': 1});
    });

    test('add same item increments qty', () {
      final notifier = container.read(cartProvider.notifier);
      notifier.add('part-123');
      notifier.add('part-123');
      expect(container.read(cartProvider)['part-123'], 2);
    });

    test('remove decrements qty', () {
      final notifier = container.read(cartProvider.notifier);
      notifier.add('part-123');
      notifier.add('part-123');
      notifier.remove('part-123');
      expect(container.read(cartProvider)['part-123'], 1);
    });

    test('remove last item removes key', () {
      final notifier = container.read(cartProvider.notifier);
      notifier.add('part-123');
      notifier.remove('part-123');
      expect(container.read(cartProvider).containsKey('part-123'), false);
    });

    test('clear empties cart', () {
      final notifier = container.read(cartProvider.notifier);
      notifier.add('part-1');
      notifier.add('part-2');
      notifier.add('part-3');
      notifier.clear();
      expect(container.read(cartProvider), isEmpty);
    });

    test('totalItems counts all quantities', () {
      final notifier = container.read(cartProvider.notifier);
      notifier.add('part-1');
      notifier.add('part-1');
      notifier.add('part-2');
      expect(notifier.totalItems, 3);
    });

    test('multiple items tracked independently', () {
      final notifier = container.read(cartProvider.notifier);
      notifier.add('part-A');
      notifier.add('part-B');
      notifier.add('part-B');
      final cart = container.read(cartProvider);
      expect(cart['part-A'], 1);
      expect(cart['part-B'], 2);
    });
  });
}
