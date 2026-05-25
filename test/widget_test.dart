// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:gamearena_new/main.dart';

void main() {
  testWidgets('App shows splash screen title', (WidgetTester tester) async {
    // Build the app and trigger a frame.
    await tester.pumpWidget(const GameArenaApp());
    await tester.pump();

    // Verify the splash screen displays the app title before the transition.
    expect(find.text('GAMEARENA'), findsOneWidget);
    expect(find.text('TOURNAMENT PLATFORM'), findsOneWidget);
  });
}
