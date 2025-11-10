import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plannerapp/main.dart';

void main() {
  testWidgets('App renders home screen and adds an item', (WidgetTester tester) async {
    await tester.pumpWidget(const PlannerApp());

    expect(find.text('PlannerApp'), findsOneWidget);
    expect(find.text('Add'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'Task 1');
    await tester.tap(find.text('Add'));
    await tester.pump();

    expect(find.text('Task 1'), findsOneWidget);
  });
}


