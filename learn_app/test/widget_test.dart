import 'package:flutter_test/flutter_test.dart';

import 'package:learn_app/main.dart';

void main() {
  testWidgets('App launches and shows home screen', (WidgetTester tester) async {
    await tester.pumpWidget(const LearnApp());

    // Verify the home screen renders with phases
    expect(find.text('Flutter UI Lab'), findsOneWidget);
    expect(find.text('Phase 2: Building Interfaces'), findsOneWidget);
    expect(find.text('Phase 3: State Management'), findsOneWidget);
    expect(find.text('Phase 4: Networking & APIs'), findsOneWidget);
    expect(find.text('Phase 5: Polish & Ship'), findsOneWidget);
  });
}
