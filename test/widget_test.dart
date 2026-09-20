import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:daily_work_mobile/main.dart';

void main() {
  testWidgets('App root widget loads smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      const ProviderScope(
        child: DailyWorkApp(),
      ),
    );

    // Verify that the DailyWorkApp root widget mounts
    expect(find.byType(DailyWorkApp), findsOneWidget);
  });
}
