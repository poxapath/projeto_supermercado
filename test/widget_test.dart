import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:projeto_supermercado/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const SupermercadoApp());
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
