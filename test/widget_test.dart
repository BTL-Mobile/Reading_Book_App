import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pht_04/main.dart';

void main() {
  testWidgets('App builds', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
