import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:gopaddler_flutter/main.dart';

void main() {
  group('GoPaddler MVP Integration Tests', () {
    testWidgets('App starts without errors', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(const MyApp());

      // Assert
      expect(find.byType(MaterialApp), findsOneWidget);
    });

    testWidgets('MVP mode - No server dependency errors', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Assert - Should load without network errors
      expect(find.byType(MaterialApp), findsOneWidget);
      // Look for potential error widgets
      expect(find.byType(ErrorWidget), findsNothing);
    });

    testWidgets('Homepage renders properly', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();

      // Assert
      // Verify that the app is showing the home screen
      expect(find.byType(Scaffold), findsWidgets);
    });
  });
}
