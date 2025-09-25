import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Enveloppe un widget dans un MaterialApp+Scaffold pour les tests.
Future<void> pumpApp(WidgetTester tester, Widget child) async {
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(body: child),
    ),
  );
  await tester.pumpAndSettle();
}
