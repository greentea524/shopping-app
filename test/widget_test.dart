import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_shop/app.dart';

void main() {
  testWidgets('Shop flow supports cart, shipping, and fake purchase', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MyApp());

    expect(find.byKey(const Key('cart-count')), findsOneWidget);
    expect(find.text('Cart: 0'), findsOneWidget);

    await tester.tap(find.text('Add').first);
    await tester.pump();
    expect(find.text('Cart: 1'), findsOneWidget);

    await tester.tap(find.byKey(const Key('open-cart-button')));
    await tester.pumpAndSettle();
    expect(find.text('Your Cart (1)'), findsOneWidget);

    await tester.tap(find.byKey(const Key('increase-Classic Tee')));
    await tester.pump();
    expect(find.byKey(const Key('qty-Classic Tee')), findsOneWidget);
    expect(find.text('Your Cart (2)'), findsOneWidget);

    await tester.tap(find.text('Express (1-2 days)'));
    await tester.pump();
    expect(find.text('\$9.99'), findsWidgets);

    await tester.scrollUntilVisible(
      find.byKey(const Key('purchase-button')),
      200,
    );
    await tester.tap(find.byKey(const Key('purchase-button')));
    await tester.pumpAndSettle();
    expect(find.text('Purchase complete'), findsOneWidget);

    await tester.tap(find.text('Back to catalog'));
    await tester.pumpAndSettle();
    expect(find.text('Cart: 0'), findsOneWidget);

    await tester.tap(find.text('History'));
    await tester.pumpAndSettle();
    expect(find.text('Order #1'), findsOneWidget);
  });
}
