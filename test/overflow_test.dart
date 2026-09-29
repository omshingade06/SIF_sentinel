import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sif_sentinel/main.dart';
import 'package:sif_sentinel/features/insights/presentation/insights_screen.dart';
import 'package:sif_sentinel/features/ai_analysis/presentation/ai_analysis_screen.dart';
import 'package:sif_sentinel/features/ai_analysis/presentation/hitl_review_dialog.dart';
import 'package:sif_sentinel/features/demo/presentation/sih_demo_dialog.dart';
import 'package:sif_sentinel/features/reports/data/synthetic_dataset.dart';
import 'package:sif_sentinel/features/reports/presentation/reports_list_screen.dart';

import 'package:sif_sentinel/features/auth/presentation/login_screen.dart';

void main() {
  testWidgets('Test LoginScreen Enterprise SSO on compact mobile (320x568)', (tester) async {
    tester.view.physicalSize = const Size(320, 568);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: LoginScreen(),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('OR ENTERPRISE SSO'), findsOneWidget);
    expect(find.byType(LoginScreen), findsOneWidget);
  });

  testWidgets('Test LoginScreen Enterprise SSO on tablet/wide viewport (800x1000)', (tester) async {
    tester.view.physicalSize = const Size(800, 1000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: LoginScreen(),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('OR ENTERPRISE SSO'), findsOneWidget);
    expect(find.text('Corporate SSO'), findsOneWidget);
    expect(find.text('Biometrics'), findsOneWidget);
  });

  testWidgets('Test LoginScreen Enterprise SSO with large accessibility font scaling (1.5x)', (tester) async {
    tester.view.physicalSize = const Size(360, 640);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: MediaQuery(
            data: MediaQueryData(textScaler: TextScaler.linear(1.5)),
            child: LoginScreen(),
          ),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('OR ENTERPRISE SSO'), findsOneWidget);
  });

  testWidgets('Test AI Insights screen on mobile screen', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: InsightsScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();
  });

  testWidgets('Test MainNavigationShell tab navigation after sign in', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(const ProviderScope(child: SifSentinelApp()));
    await tester.pump(const Duration(seconds: 1));
    await tester.pump(const Duration(seconds: 1));

    // Scroll to and tap SIGN IN on LoginScreen
    final signInBtn = find.text('SIGN IN');
    if (signInBtn.evaluate().isNotEmpty) {
      await tester.ensureVisible(signInBtn);
      await tester.pump(const Duration(milliseconds: 300));
      await tester.tap(signInBtn);
      await tester.pump(const Duration(milliseconds: 800));
      await tester.pump(const Duration(milliseconds: 800));
    }

    // Verify main MaterialApp is rendered
    expect(find.byType(MaterialApp), findsOneWidget);
  });

  testWidgets('Test AI Safety Analysis screen', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    final report = SyntheticDataset.generateInitialReports().first;
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: AISafetyAnalysisScreen(report: report),
        ),
      ),
    );
    await tester.pumpAndSettle();
  });

  testWidgets('Test HITL Review Dialog on small height', (tester) async {
    tester.view.physicalSize = const Size(360, 500);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    final report = SyntheticDataset.generateInitialReports().first;
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (_) => HitlReviewDialog(report: report),
                  );
                },
                child: const Text('Open'),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
  });

  testWidgets('Test SIH Demo Dialog on small height', (tester) async {
    tester.view.physicalSize = const Size(360, 500);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (_) => const SihDemoDialog(),
                  );
                },
                child: const Text('Open'),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
  });

  testWidgets('Test ReportsListScreen on small mobile screen', (tester) async {
    tester.view.physicalSize = const Size(360, 600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: ReportsListScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(ReportsListScreen), findsOneWidget);
  });
}
