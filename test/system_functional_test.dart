import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sif_sentinel/features/ai_analysis/domain/oilfield_nlp_engine.dart';
import 'package:sif_sentinel/features/auth/providers/auth_provider.dart';
import 'package:sif_sentinel/features/reports/providers/reports_provider.dart';
import 'package:sif_sentinel/shared/models/corrective_action_model.dart';
import 'package:sif_sentinel/shared/models/notification_model.dart';
import 'package:sif_sentinel/shared/models/report_model.dart';
import 'package:sif_sentinel/shared/models/sif_analysis_model.dart';
import 'package:sif_sentinel/core/security/rbac_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues({});

  group('1. Authentication & Role-Based Access Control Tests', () {
    test('Default auth state is unauthenticated showing login screen', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final authState = container.read(authProvider);
      expect(authState.isAuthenticated, isFalse);
      expect(authState.user.userRole, equals(UserRole.hseOfficer));
    });

    test('Switching user roles works accurately', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(authProvider.notifier);

      notifier.switchRole('HSE Directorate');
      expect(container.read(authProvider).user.userRole, equals(UserRole.hseDirectorate));

      notifier.switchRole('site_supervisor');
      expect(container.read(authProvider).user.userRole, equals(UserRole.siteSupervisor));

      notifier.switchRole('engineer');
      expect(container.read(authProvider).user.userRole, equals(UserRole.engineer));

      notifier.switchRole('administrator');
      expect(container.read(authProvider).user.userRole, equals(UserRole.administrator));
    });

    test('Logout and Login lifecycle', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(authProvider.notifier);
      await notifier.logout();
      expect(container.read(authProvider).isAuthenticated, isFalse);

      final success = await notifier.login('OIL-EMP-2491', 'OilIndia@2026');
      expect(success, isTrue);
      expect(container.read(authProvider).isAuthenticated, isTrue);
      expect(container.read(authProvider).user.employeeId, equals('OIL-EMP-2491'));
    });

    test('RBAC Permission Matrix verification', () {
      // Engineer cannot override AI
      expect(RbacService.hasPermission(UserRole.engineer, Permission.overrideAiClassification), isFalse);

      // HSE Officer can override AI & change LSR
      expect(RbacService.hasPermission(UserRole.hseOfficer, Permission.overrideAiClassification), isTrue);
      expect(RbacService.hasPermission(UserRole.hseOfficer, Permission.modifyLifeSavingRule), isTrue);

      // Administrator can manage users & configure taxonomy
      expect(RbacService.hasPermission(UserRole.administrator, Permission.manageUsers), isTrue);
      expect(RbacService.hasPermission(UserRole.administrator, Permission.configureTaxonomy), isTrue);
    });
  });

  group('2. Oilfield Domain NLP Engine Comprehensive Inference Tests', () {
    test('Detects Toxic H2S Gas hazard as Critical SIF Precursor', () {
      const text =
          'Worker smelled rotten eggs near wellhead christmas tree #14 with H2S alarm triggered at 25 ppm. Gas detector calibration was expired and no emergency escape pack was available.';

      final analysis = OilfieldNLPEngine.analyzeObservation(text);
      expect(analysis.sifPotential, equals(SifPotential.critical));
      expect(analysis.detectedHazards.any((h) => h.contains('Gas') || h.contains('H2S') || h.contains('Toxic')), isTrue);
      expect(analysis.workerExposure, isTrue);
      expect(analysis.confidence, greaterThanOrEqualTo(0.8));
    });

    test('Detects Heavy Lifting & Rigging failure as High or Critical SIF Precursor', () {
      const text =
          'During crane offloading of 12-ton drill pipe bundle, the wire rope sling snapped due to frayed strand. The load dropped 4 meters onto the drill floor while 3 roustabouts were standing directly in the drop zone.';

      final analysis = OilfieldNLPEngine.analyzeObservation(text);
      expect(
        analysis.sifPotential == SifPotential.critical || analysis.sifPotential == SifPotential.high,
        isTrue,
      );
      expect(analysis.workerExposure, isTrue);
      expect(analysis.recommendedActions.isNotEmpty, isTrue);
    });

    test('Detects Well Control / Kick hazard as Critical SIF Precursor', () {
      const text =
          'Drilling crew encountered unexpected gas kick while pulling out of hole at Moran Well #44. Mud weight was inadequate and BOP accumulator bottle pressure dropped below minimum operating limit.';

      final analysis = OilfieldNLPEngine.analyzeObservation(text);
      expect(analysis.sifPotential, equals(SifPotential.critical));
      expect(analysis.evidenceSpans.isNotEmpty, isTrue);
    });

    test('Classifies routine non-SIF housekeeping as Low risk', () {
      const text = 'Slight mud spatter on floor grating in pump room after routine water flush.';

      final analysis = OilfieldNLPEngine.analyzeObservation(text);
      expect(analysis.sifPotential, equals(SifPotential.low));
    });
  });

  group('3. Reports State Management & Audit Flow Tests', () {
    test('Can create a new safety observation report', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(reportsProvider.notifier);
      final initialCount = container.read(reportsProvider).length;

      final newReport = ReportModel(
        id: 'OIL-2026-TEST-999',
        observationText: 'Pin-hole hydrocarbon seepage observed on 6-inch test separator manifold line.',
        reportType: 'Near-Miss',
        site: 'Duliajan Main Complex',
        department: 'Production & Field Operations',
        workActivity: 'Routine Flowline Patrol',
        equipment: 'High Pressure Manifold Line 6',
        submittedByName: 'Pranab Jyoti Baruah',
        submittedByRole: 'HSE Officer',
        submittedAt: DateTime.now(),
        status: ReportStatus.newReport,
        sifAnalysis: OilfieldNLPEngine.analyzeObservation('Pin-hole hydrocarbon seepage observed on 6-inch test separator manifold line.'),
        auditTrail: [
          ReportAuditEntry(
            action: 'Report Submitted',
            performedBy: 'Pranab Jyoti Baruah',
            details: 'Initial report logged from field mobile device.',
            timestamp: DateTime.now(),
          )
        ],
      );

      notifier.addReport(newReport);
      final reports = container.read(reportsProvider);

      expect(reports.length, equals(initialCount + 1));
      expect(reports.first.id, equals('OIL-2026-TEST-999'));
    });

    test('Report status update generates audit log entry', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(reportsProvider.notifier);
      final firstReport = container.read(reportsProvider).first;

      notifier.updateReportStatus(firstReport.id, ReportStatus.actionAssigned);

      final updated = container.read(reportsProvider).firstWhere((r) => r.id == firstReport.id);
      expect(updated.status, equals(ReportStatus.actionAssigned));
      expect(updated.auditTrail.last.action, contains('Status updated to Action Assigned'));
    });

    test('Human-in-the-Loop validation updates SIF analysis and audit trail', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(reportsProvider.notifier);
      final firstReport = container.read(reportsProvider).first;

      final modifiedAnalysis = (firstReport.sifAnalysis ?? SifAnalysisModel(
        sifPotential: SifPotential.high,
        confidence: 0.90,
        detectedHazards: ['Confined Space'],
        detectedUnsafeActs: [],
        detectedUnsafeConditions: [],
        potentialConsequences: [],
        workerExposure: true,
        exposureDetails: 'Worker in vessel',
        explanation: 'Test explanation',
        evidenceSpans: [],
        riskFactors: [],
        recommendedActions: [],
        analyzedAt: DateTime.now(),
      )).copyWith(
        sifPotential: SifPotential.critical,
      );

      notifier.updateSifAnalysis(
        firstReport.id,
        modifiedAnalysis,
        'Dr. Ranjit Saikia',
        'Verified critical precursor risk due to unmonitored gas pocket.',
      );

      final updated = container.read(reportsProvider).firstWhere((r) => r.id == firstReport.id);
      expect(updated.sifAnalysis?.isHumanValidated, isTrue);
      expect(updated.sifAnalysis?.validatedBy, equals('Dr. Ranjit Saikia'));
      expect(updated.sifAnalysis?.sifPotential, equals(SifPotential.critical));
      expect(updated.auditTrail.last.action, equals('Human-in-the-Loop Validation'));
    });

    test('Search and filter providers operate correctly with site scope', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      // Search query filtering
      container.read(reportSearchQueryProvider.notifier).state = 'Duliajan';
      var filtered = container.read(filteredReportsProvider);
      expect(filtered.every((r) => r.site.contains('Duliajan') || r.observationText.contains('Duliajan') || r.id.contains('Duliajan')), isTrue);

      // Reset query
      container.read(reportSearchQueryProvider.notifier).state = '';

      // Filter by Risk
      container.read(selectedRiskFilterProvider.notifier).state = SifPotential.critical;
      filtered = container.read(filteredReportsProvider);
      expect(filtered.every((r) => r.sifAnalysis?.sifPotential == SifPotential.critical), isTrue);
    });
  });

  group('4. Corrective Actions (CAPA) Lifecycle Tests', () {
    test('Can create, progress, and complete a corrective action', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(actionsProvider.notifier);

      final testAction = CorrectiveActionModel(
        id: 'ACT-TEST-001',
        reportId: 'OIL-2026-00428',
        title: 'Recalibrate 4-gas atmospheric monitors across Sector 2',
        description: 'Verify sensor calibration and replace oxygen sensor cell.',
        assignedToName: 'Suraj Dutta',
        assignedToRole: 'Senior Instrumentation Engineer',
        site: 'Duliajan Main Complex',
        priority: ActionPriority.critical,
        status: ActionStatus.assigned,
        createdAt: DateTime.now(),
        dueDate: DateTime.now().add(const Duration(days: 2)),
        progress: 0.0,
      );

      notifier.addAction(testAction);
      expect(container.read(actionsProvider).first.id, equals('ACT-TEST-001'));

      // Progress update
      notifier.updateActionStatus('ACT-TEST-001', ActionStatus.inProgress, progress: 0.5);
      var updated = container.read(actionsProvider).firstWhere((a) => a.id == 'ACT-TEST-001');
      expect(updated.status, equals(ActionStatus.inProgress));
      expect(updated.progress, equals(0.5));

      // Complete action
      notifier.updateActionStatus(
        'ACT-TEST-001',
        ActionStatus.completed,
        verificationNotes: 'All 8 gas detectors certified with bump test stamp.',
        verifiedByName: 'Biren Gogoi',
      );
      updated = container.read(actionsProvider).firstWhere((a) => a.id == 'ACT-TEST-001');
      expect(updated.status, equals(ActionStatus.completed));
      expect(updated.progress, equals(1.0));
      expect(updated.completedAt, isNotNull);
      expect(updated.closureVerificationNotes, contains('certified with bump test stamp'));
    });
  });

  group('5. Safety Notifications & Alerts Lifecycle Tests', () {
    test('Can receive and mark safety notifications as read', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(notificationsProvider.notifier);

      final testNotification = NotificationModel(
        id: 'NOTIF-TEST-1',
        title: 'Emergency H2S Alert Test',
        message: 'High H2S detection at Wellhead Christmas Tree #14',
        type: NotificationType.criticalSifAlert,
        timestamp: DateTime.now(),
        isRead: false,
      );

      notifier.addNotification(testNotification);
      expect(container.read(notificationsProvider).first.id, equals('NOTIF-TEST-1'));
      expect(container.read(notificationsProvider).first.isRead, isFalse);

      notifier.markAsRead('NOTIF-TEST-1');
      expect(container.read(notificationsProvider).firstWhere((n) => n.id == 'NOTIF-TEST-1').isRead, isTrue);

      notifier.markAllAsRead();
      expect(container.read(notificationsProvider).every((n) => n.isRead), isTrue);
    });
  });
}
