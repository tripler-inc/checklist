import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:checklist/main.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('shows checklist screen basics', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    expect(find.text('Checklist'), findsOneWidget);
    expect(find.text('Add item'), findsOneWidget);
    expect(find.text('Add'), findsOneWidget);
  });

  testWidgets('loads persisted checklist items', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({
      'checklist_items': jsonEncode([
        {'id': 'one', 'text': 'Persisted task', 'checked': true}
      ])
    });

    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    expect(find.text('Persisted task'), findsOneWidget);
    final checkbox = tester.widget<Checkbox>(find.byType(Checkbox).first);
    expect(checkbox.value, isTrue);
  });

  testWidgets('adds, toggles, edits, and deletes an item',
      (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).first, 'Buy milk');
    await tester.tap(find.text('Add'));
    await tester.pumpAndSettle();

    expect(find.text('Buy milk'), findsOneWidget);

    var checkbox = tester.widget<Checkbox>(find.byType(Checkbox).first);
    expect(checkbox.value, isFalse);

    await tester.tap(find.byType(Checkbox).first);
    await tester.pumpAndSettle();

    checkbox = tester.widget<Checkbox>(find.byType(Checkbox).first);
    expect(checkbox.value, isTrue);

    await tester.tap(find.text('Buy milk'));
    await tester.pumpAndSettle();

    expect(find.text('Edit item'), findsOneWidget);
    await tester.enterText(find.byType(TextField).last, 'Buy bread');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(find.text('Buy bread'), findsOneWidget);
    expect(find.text('Buy milk'), findsNothing);

    await tester.drag(find.text('Buy bread'), const Offset(-600, 0));
    await tester.pumpAndSettle();

    expect(find.text('Buy bread'), findsNothing);
  });

  testWidgets('reorders checklist items', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).first, 'Task A');
    await tester.tap(find.text('Add'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).first, 'Task B');
    await tester.tap(find.text('Add'));
    await tester.pumpAndSettle();

    final dragHandles = find.byIcon(Icons.drag_handle);
    expect(dragHandles, findsNWidgets(2));

    await tester.drag(dragHandles.at(1), const Offset(0, -300));
    await tester.pumpAndSettle();

    final taskBTop = tester.getTopLeft(find.text('Task B')).dy;
    final taskATop = tester.getTopLeft(find.text('Task A')).dy;
    expect(taskBTop, lessThan(taskATop));
  });
}
