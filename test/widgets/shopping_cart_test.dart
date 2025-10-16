import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_testing_lab/widgets/shopping_cart.dart';

void main() {
  group(' CartManager Unit Tests', () {
    late CartManager cart;

    setUp(() {
      cart = CartManager();
    });

    test('Add item should increase total items', () {
      cart.addItem('1', 'iPhone', 999.99, discount: 0.1);
      expect(cart.totalItems, 1);
    });

    test('Adding same item should increase its quantity', () {
      cart.addItem('1', 'iPhone', 999.99);
      cart.addItem('1', 'iPhone', 999.99);
      expect(cart.items.first.quantity, 2);
    });

    test('Remove item should make cart empty', () {
      cart.addItem('1', 'iPhone', 999.99);
      cart.removeItem('1');
      expect(cart.items, isEmpty);
    });

    test('Clear cart removes all items', () {
      cart.addItem('1', 'iPhone', 999.99);
      cart.addItem('2', 'Galaxy', 899.99);
      cart.clearCart();
      expect(cart.items.length, 0);
    });

    test('Subtotal, discount, and totalAmount are calculated correctly', () {
      cart.addItem('1', 'iPhone', 100.0, discount: 0.1);
      cart.addItem('2', 'Galaxy', 200.0, discount: 0.2);
      expect(cart.subtotal, 300.0);
      expect(cart.totalDiscount, 50.0);
      expect(cart.totalAmount, 250.0);
    });
  });

  group(' ShoppingCart Widget Tests', () {
    testWidgets('Should show buttons and empty text at start', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: Scaffold(body: ShoppingCart())));

      expect(find.text('Add iPhone'), findsOneWidget);
      expect(find.text('Add Galaxy'), findsOneWidget);
      expect(find.text('Add iPad'), findsOneWidget);
      expect(find.text('Cart is empty'), findsOneWidget);
    });

    testWidgets('Adding iPhone updates total items and shows in list', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: Scaffold(body: ShoppingCart())));

      await tester.tap(find.text('Add iPhone'));
      await tester.pump();

      expect(find.text('Apple iPhone'), findsOneWidget);
      expect(find.textContaining('Total Items: 1'), findsOneWidget);
    });

    testWidgets('Clear Cart button empties the list', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: Scaffold(body: ShoppingCart())));

      await tester.tap(find.text('Add iPhone'));
      await tester.pump();
      expect(find.text('Apple iPhone'), findsOneWidget);

      await tester.tap(find.text('Clear Cart'));
      await tester.pump();

      expect(find.text('Cart is empty'), findsOneWidget);
    });

    testWidgets('Increase and decrease quantity works', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: Scaffold(body: ShoppingCart())));

      await tester.tap(find.text('Add iPhone'));
      await tester.pump();
// Initial quantity should be 1
      expect(find.text('1'), findsOneWidget);
      await tester.tap(find.byIcon(Icons.add));
      await tester.pump();
      expect(find.text('2'), findsOneWidget);

      // Decrease quantity
      await tester.tap(find.byIcon(Icons.remove));
      await tester.pump();
      expect(find.text('1'), findsOneWidget);
    });

    testWidgets('Remove item deletes it from list', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: Scaffold(body: ShoppingCart())));

      await tester.tap(find.text('Add iPhone'));
      await tester.pump();

      await tester.tap(find.byIcon(Icons.delete));
      await tester.pump();

      expect(find.text('Cart is empty'), findsOneWidget);
    });
  });
}
