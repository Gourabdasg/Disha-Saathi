// Basic smoke test for Disha Saathi.
//
// This verifies the app boots to the splash screen without throwing.
// Add more widget/unit tests here as the app grows.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:disha_saathi/main.dart';

void main() {
  testWidgets('App boots to splash screen', (WidgetTester tester) async {
    await tester.pumpWidget(const DishaSaathiApp());

    // Splash screen shows the app name and CTA.
    expect(find.text('Disha Saathi'), findsOneWidget);
    expect(find.textContaining('Tap to Begin'), findsOneWidget);
  });
}
