import 'dart:convert';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:checklist/main.dart';

void main() {
  String formatDate(DateTime date) {
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '${date.year}-$month-$day';
  }

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('shows checklist screen basics', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    expect(find.text('Checklist'), findsOneWidget);
    expect(find.byIcon(Icons.save), findsOneWidget);
    expect(find.byIcon(Icons.add), findsOneWidget);
    expect(find.byIcon(Icons.settings), findsOneWidget);
    expect(find.text('Add item'), findsNothing);
    expect(find.text('Add'), findsNothing);

    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();

    expect(find.text('Add item'), findsOneWidget);
    expect(find.text('Add'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();

    expect(find.text('Add item'), findsNothing);
    expect(find.text('Add'), findsNothing);
  });

  testWidgets('settings New List clears items and resets title',
      (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).first, 'Task to clear');
    await tester.tap(find.text('Add'));
    await tester.pumpAndSettle();
    expect(find.text('Task to clear'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.save));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).last, 'Existing List');
    await tester.tap(find.text('Save').last);
    await tester.pumpAndSettle();

    await tester.tap(
      find
          .descendant(
            of: find.byType(ListTile),
            matching: find.text('Existing List'),
          )
          .first,
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.settings));
    await tester.pumpAndSettle();

    expect(find.text('Settings'), findsOneWidget);
    expect(find.text('Mode'), findsOneWidget);
    expect(find.text('New List'), findsOneWidget);
    expect(find.text('About'), findsOneWidget);

    await tester.tap(find.text('New List'));
    await tester.pumpAndSettle();

    expect(find.text('Checklist'), findsOneWidget);
    expect(find.text('Task to clear'), findsNothing);
    expect(find.byType(Checkbox), findsNothing);
  });

  testWidgets('settings About shows app details', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.settings));
    await tester.pumpAndSettle();

    await tester.tap(find.text('About'));
    await tester.pumpAndSettle();

    expect(find.text('About'), findsOneWidget);
    expect(find.text('Checklist'), findsOneWidget);
    expect(find.text('Version'), findsOneWidget);
    expect(find.text('Last compile date'), findsOneWidget);
    expect(find.text('1.0'), findsOneWidget);
    expect(find.text(formatDate(DateTime.now())), findsOneWidget);
    expect(
      find.textContaining('create and manage reusable lists'),
      findsOneWidget,
    );
  });

  testWidgets('saves named lists and loads them with unchecked items',
      (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).first, 'Saved Task');
    await tester.tap(find.text('Add'));
    await tester.pumpAndSettle();

    await tester.tap(find.byType(Checkbox).first);
    await tester.pumpAndSettle();
    expect(tester.widget<Checkbox>(find.byType(Checkbox).first).value, isTrue);

    await tester.tap(find.byIcon(Icons.save));
    await tester.pumpAndSettle();

    expect(find.text('Saved lists'), findsOneWidget);

    await tester.enterText(find.byType(TextField).last, 'Groceries');
    await tester.tap(find.text('Save').last);
    await tester.pumpAndSettle();

    expect(
      find.descendant(of: find.byType(ListTile), matching: find.text('Groceries')),
      findsOneWidget,
    );

    await tester.longPress(
      find
          .descendant(
            of: find.byType(ListTile),
            matching: find.text('Groceries'),
          )
          .first,
    );
    await tester.pumpAndSettle();

    final nameField = tester.widget<TextField>(find.byType(TextField).last);
    expect(nameField.controller?.text, 'Groceries');

    await tester.tap(
      find
          .descendant(
            of: find.byType(ListTile),
            matching: find.text('Groceries'),
          )
          .first,
    );
    await tester.pumpAndSettle();

    expect(
      find.descendant(of: find.byType(AppBar), matching: find.text('Groceries')),
      findsOneWidget,
    );
    expect(find.text('Saved Task'), findsOneWidget);
    expect(tester.widget<Checkbox>(find.byType(Checkbox).first).value, isFalse);
  });

  testWidgets('swipe delete saved list asks confirmation',
      (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).first, 'Delete candidate');
    await tester.tap(find.text('Add'));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.save));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).last, 'Delete Me');
    await tester.tap(find.text('Save').last);
    await tester.pumpAndSettle();

    final savedListLabel = find
        .descendant(of: find.byType(ListTile), matching: find.text('Delete Me'))
        .first;
    expect(savedListLabel, findsOneWidget);

    await tester.drag(savedListLabel, const Offset(-500, 0));
    await tester.pumpAndSettle();

    expect(find.text('Delete list'), findsOneWidget);
    expect(
      find.text('Are you sure you want to delete list Delete Me?'),
      findsOneWidget,
    );

    await tester.tap(find.text('No'));
    await tester.pumpAndSettle();

    expect(
      find.descendant(of: find.byType(ListTile), matching: find.text('Delete Me')),
      findsOneWidget,
    );

    await tester.drag(savedListLabel, const Offset(-500, 0));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Yes'));
    await tester.pumpAndSettle();

    expect(
      find.descendant(of: find.byType(ListTile), matching: find.text('Delete Me')),
      findsNothing,
    );
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

    await tester.tap(find.byIcon(Icons.add));
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

    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).first, 'Task A');
    await tester.tap(find.text('Add'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).first, 'Task B');
    await tester.tap(find.text('Add'));
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.drag_handle), findsNothing);

    final taskBText = find.text('Task B');
    final taskBCenter = tester.getCenter(taskBText);
    final gesture = await tester.startGesture(taskBCenter);
    await tester.pump(kLongPressTimeout + const Duration(milliseconds: 100));
    await gesture.moveBy(const Offset(0, -300));
    await gesture.up();
    await tester.pumpAndSettle();

    final taskBTop = tester.getTopLeft(find.text('Task B')).dy;
    final taskATop = tester.getTopLeft(find.text('Task A')).dy;
    expect(taskBTop, lessThan(taskATop));
  });
}
