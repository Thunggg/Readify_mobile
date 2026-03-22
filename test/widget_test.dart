// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mobile/main.dart';

void main() {
  testWidgets('Register screen smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    expect(find.text('Register'), findsOneWidget);

    // Basic fields exist
    expect(find.widgetWithText(TextFormField, 'First name'), findsOneWidget);
    expect(find.widgetWithText(TextFormField, 'Last name'), findsOneWidget);
    expect(find.widgetWithText(TextFormField, 'Email'), findsOneWidget);
    expect(find.widgetWithText(TextFormField, 'Password'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('Create account'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Create account'), findsOneWidget);

    // No counter UI anymore
    expect(find.byIcon(Icons.add), findsNothing);
  });
}
