import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ticktasker/main.dart';

void main() {
  testWidgets('shows highlight and task list', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: TickTaskerApp()));
    await tester.pumpAndSettle();

    expect(find.text('TickTasker'), findsOneWidget);
    expect(find.text("Ship today's highlight project"), findsOneWidget);
    expect(find.text('Draft outline for newsletter'), findsOneWidget);
  });
}
