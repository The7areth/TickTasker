import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ticktasker/main.dart';

void main() {
  testWidgets('renders TickTasker home sections', (WidgetTester tester) async {
    await tester.pumpWidget(const TickTaskerApp());

    expect(find.text('TickTasker'), findsOneWidget);
    expect(find.text('Daily Highlight'), findsOneWidget);
    expect(find.text('Commitment Slider (0–3)'), findsOneWidget);
    expect(find.text('Two-Day Rule'), findsOneWidget);
    expect(find.text('Two-Minute Tasks'), findsOneWidget);
    expect(find.text('Study → Write Pipeline'), findsOneWidget);
    expect(find.text('Commitment level: 1 / 3'), findsOneWidget);
  });

  testWidgets('updates commitment slider value', (WidgetTester tester) async {
    await tester.pumpWidget(const TickTaskerApp());

    final slider = tester.widget<Slider>(find.byType(Slider));
    slider.onChanged?.call(3);
    await tester.pump();

    expect(find.text('Commitment level: 3 / 3'), findsOneWidget);
  });

  testWidgets('filters tasks to two-minute only', (WidgetTester tester) async {
    await tester.pumpWidget(const TickTaskerApp());

    expect(find.text('Outline weekly report (15 min)'), findsOneWidget);

    await tester.tap(find.byType(Switch));
    await tester.pumpAndSettle();

    expect(find.text('Outline weekly report (15 min)'), findsNothing);
    expect(find.text('Reply to the design question'), findsOneWidget);
    expect(find.text('Schedule one focus block'), findsOneWidget);
  });
}
