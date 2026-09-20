import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:daily_work_mobile/views/home/main_scaffold.dart';
import 'package:daily_work_mobile/core/theme/app_theme.dart';

void main() {
  testWidgets('MainScaffold navigation and theme switching test', (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          theme: AppTheme.lightTheme,
          home: const MainScaffold(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Switch to Settings tab (index 4)
    await tester.tap(find.text('Settings'));
    await tester.pumpAndSettle();

    // Tap AMOLED theme mode card
    final amoledFinder = find.text('AMOLED');
    if (amoledFinder.evaluate().isNotEmpty) {
      await tester.tap(amoledFinder);
      await tester.pumpAndSettle();
    }
  });
}
