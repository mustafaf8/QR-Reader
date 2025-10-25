// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:qr_okuyucu/main.dart';
import 'package:qr_okuyucu/services/theme_service.dart';
import 'package:qr_okuyucu/providers/locale_provider.dart';

void main() {
  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
    // Create a mock theme service for testing
    final themeService = ThemeService();
    await themeService.initialize();

    // Create a mock locale provider for testing
    final localeProvider = LocaleProvider();
    await localeProvider.initialize();

    // Build our app and trigger a frame.
    await tester.pumpWidget(
      QRReaderApp(themeService: themeService, localeProvider: localeProvider),
    );

    // Verify that our counter starts at 0.
    expect(find.text('0'), findsOneWidget);
    expect(find.text('1'), findsNothing);

    // Tap the '+' icon and trigger a frame.
    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();

    // Verify that our counter has incremented.
    expect(find.text('0'), findsNothing);
    expect(find.text('1'), findsOneWidget);
  });
}
