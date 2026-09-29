import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sif_sentinel/main.dart';

void main() {
  testWidgets('SIF Sentinel App Smoke Test', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: SifSentinelApp()));
    await tester.pump(const Duration(milliseconds: 500));

    // Verify SIF Sentinel title or login screen presence
    expect(find.text('SIF SENTINEL'), findsWidgets);
  });
}
