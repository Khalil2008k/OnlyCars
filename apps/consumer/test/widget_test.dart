import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:consumer/screens/auth/login_screen.dart';
import 'package:consumer/screens/marketplace/marketplace_screen.dart';
import 'package:consumer/screens/orders/rate_workshop_screen.dart';

void main() {
  group('LoginScreen', () {
    testWidgets('renders phone input and send OTP button', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Directionality(
              textDirection: TextDirection.rtl,
              child: LoginScreen(),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Should have a text field for phone number
      expect(find.byType(TextField), findsWidgets);
    });
  });

  group('RateWorkshopScreen', () {
    testWidgets('renders 5 star icons', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Directionality(
            textDirection: TextDirection.rtl,
            child: RateWorkshopScreen(orderId: 'test-order-123456'),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Should render 5 star icons (either filled or outline)
      final starIcons = find.byIcon(Icons.star_outline_rounded);
      expect(starIcons, findsNWidgets(5));
    });
  });
}
