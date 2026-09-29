import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/models/report_model.dart';
import '../../../shared/models/corrective_action_model.dart';
import '../../../shared/models/notification_model.dart';
import '../../../shared/models/sif_analysis_model.dart';
import '../../../shared/models/site_model.dart';
import '../../../shared/models/audit_log_model.dart';
import '../../../core/security/rbac_service.dart';
import '../../auth/providers/auth_provider.dart';
import '../data/synthetic_dataset.dart';

// Reports State Notifier
class ReportsNotifier extends StateNotifier<List<ReportModel>> {
  ReportsNotifier() : super(SyntheticDataset.generateInitialReports());

  void addReport(ReportModel report) {
    state = [report, ...state];
  }

  void updateReportStatus(String id, ReportStatus newStatus) {
    state = state.map((r) {
      if (r.id == id) {
        final newAudit = List<ReportAuditEntry>.from(r.auditTrail)
          ..add(ReportAuditEntry(
            action: 'Status updated to ${newStatus.label}',
            performedBy: 'HSE Authority',
            details: 'Safety workflow status transition.',
            timestamp: DateTime.now(),
          ));
        return r.copyWith(status: newStatus, auditTrail: newAudit);
      }
      return r;
    }).toList();
  }

  void updateSifAnalysis(String id, SifAnalysisModel newAnalysis, String validatorName, String notes) {
    state = state.map((r) {
      if (r.id == id) {
        final updatedAnalysis = newAnalysis.copyWith(
          isHumanValidated: true,
          validatedBy: validatorName,
          validationNotes: notes,
        );
        final newAudit = List<ReportAuditEntry>.from(r.auditTrail)
          ..add(ReportAuditEntry(
            action: 'Human-in-the-Loop Validation',
            performedBy: validatorName,
            details: 'AI classification calibrated: SIF is ${updatedAnalysis.sifPotential.label}. $notes',
            timestamp: DateTime.now(),
          ));
        return r.copyWith(
          sifAnalysis: updatedAnalysis,
          auditTrail: newAudit,
          status: ReportStatus.underReview,
        );
      }
      return r;
    }).toList();
  }

  void addComment(String reportId, ReportComment comment) {
    state = state.map((r) {
      if (r.id == reportId) {
        return r.copyWith(
          comments: [...r.comments, comment],
        );
      }
      return r;
    }).toList();
  }

  void resetToDemoData() {
    state = SyntheticDataset.generateInitialReports();
  }
}

final reportsProvider = StateNotifierProvider<ReportsNotifier, List<ReportModel>>((ref) {
  return ReportsNotifier();
});

// Filter Providers for Search & Reports List
final reportSearchQueryProvider = StateProvider<String>((ref) => '');
final selectedReportTypeFilterProvider = StateProvider<String?>((ref) => null);
final selectedRiskFilterProvider = StateProvider<SifPotential?>((ref) => null);
final selectedSiteFilterProvider = StateProvider<String?>((ref) => null);
final selectedHazardFilterProvider = StateProvider<String?>((ref) => null);
final selectedStatusFilterProvider = StateProvider<ReportStatus?>((ref) => null);

// Section 13: Data-Level Security & Role-Based Scope Filtered Reports Provider
final filteredReportsProvider = Provider<List<ReportModel>>((ref) {
  final allReports = ref.watch(reportsProvider);
  final authState = ref.watch(authProvider);
  final currentUser = authState.user;

  final query = ref.watch(reportSearchQueryProvider).trim().toLowerCase();
  final typeFilter = ref.watch(selectedReportTypeFilterProvider);
  final riskFilter = ref.watch(selectedRiskFilterProvider);
  final siteFilter = ref.watch(selectedSiteFilterProvider);
  final hazardFilter = ref.watch(selectedHazardFilterProvider);
  final statusFilter = ref.watch(selectedStatusFilterProvider);

  return allReports.where((r) {
    // 1. Data-Level RBAC & Site Jurisdiction Boundary Enforcement
    if (!currentUser.isSiteAuthorized(r.site)) {
      return false;
    }

    // 2. Text Search Query
    if (query.isNotEmpty) {
      final matchesQuery = r.id.toLowerCase().contains(query) ||
          r.observationText.toLowerCase().contains(query) ||
          r.equipment.toLowerCase().contains(query) ||
          r.site.toLowerCase().contains(query) ||
          r.workActivity.toLowerCase().contains(query) ||
          (r.sifAnalysis?.detectedHazards.any((h) => h.toLowerCase().contains(query)) ?? false);
      if (!matchesQuery) return false;
    }

    // 3. Report Type Filter
    if (typeFilter != null && typeFilter.isNotEmpty && r.reportType != typeFilter) {
      return false;
    }

    // 4. SIF Risk Potential Filter
    if (riskFilter != null && r.sifAnalysis?.sifPotential != riskFilter) {
      return false;
    }

    // 5. Site Dropdown Filter
    if (siteFilter != null && siteFilter.isNotEmpty && r.site != siteFilter) {
      return false;
    }

    // 6. Hazard Taxonomy Filter
    if (hazardFilter != null && hazardFilter.isNotEmpty) {
      final hasHazard = r.sifAnalysis?.detectedHazards.any((h) => h.contains(hazardFilter)) ?? false;
      if (!hasHazard) return false;
    }

    // 7. Status Filter
    if (statusFilter != null && r.status != statusFilter) {
      return false;
    }

    return true;
  }).toList();
});

// Corrective Actions Notifier
class ActionsNotifier extends StateNotifier<List<CorrectiveActionModel>> {
  ActionsNotifier() : super(SyntheticDataset.generateInitialActions());

  void addAction(CorrectiveActionModel action) {
    state = [action, ...state];
  }

  void updateActionStatus(
    String actionId,
    ActionStatus newStatus, {
    double? progress,
    String? verificationNotes,
    String? verifiedByName,
  }) {
    state = state.map((a) {
      if (a.id == actionId) {
        return a.copyWith(
          status: newStatus,
          progress: progress ?? (newStatus == ActionStatus.completed ? 1.0 : a.progress),
          closureVerificationNotes: verificationNotes,
          verifiedByName: verifiedByName,
          completedAt: newStatus == ActionStatus.completed ? DateTime.now() : null,
        );
      }
      return a;
    }).toList();
  }

  void resetToDemoData() {
    state = SyntheticDataset.generateInitialActions();
  }
}

final actionsProvider = StateNotifierProvider<ActionsNotifier, List<CorrectiveActionModel>>((ref) {
  return ActionsNotifier();
});

// Role & Site Scoped Actions Provider
final filteredActionsProvider = Provider<List<CorrectiveActionModel>>((ref) {
  final allActions = ref.watch(actionsProvider);
  final authState = ref.watch(authProvider);
  final currentUser = authState.user;

  return allActions.where((a) {
    // If user is Engineer, prioritize/filter by their assigned actions or site
    if (currentUser.userRole == UserRole.engineer) {
      if (a.assignedToName == currentUser.name) return true;
      return currentUser.isSiteAuthorized(a.site);
    }
    return currentUser.isSiteAuthorized(a.site);
  }).toList();
});

// Notifications Notifier
class NotificationsNotifier extends StateNotifier<List<NotificationModel>> {
  NotificationsNotifier() : super(SyntheticDataset.generateInitialNotifications());

  void markAsRead(String id) {
    state = state.map((n) => n.id == id ? n.copyWith(isRead: true) : n).toList();
  }

  void markAllAsRead() {
    state = state.map((n) => n.copyWith(isRead: true)).toList();
  }

  void addNotification(NotificationModel notification) {
    state = [notification, ...state];
  }
}

final notificationsProvider = StateNotifierProvider<NotificationsNotifier, List<NotificationModel>>((ref) {
  return NotificationsNotifier();
});

// Operational Sites Provider
final sitesProvider = Provider<List<SiteModel>>((ref) {
  return [
    const SiteModel(
      id: 'SITE-01',
      name: 'Duliajan Main Complex',
      code: 'DLN-HQ',
      type: 'Central Processing & Headquarter',
      latitude: 27.3592,
      longitude: 95.3188,
      activeRigs: 8,
      openReports: 34,
      criticalAlerts: 3,
      safetyHealthScore: 84.0,
    ),
    const SiteModel(
      id: 'SITE-02',
      name: 'Digboi Oil Field',
      code: 'DGB-01',
      type: 'Historic Production & Processing Area',
      latitude: 27.3820,
      longitude: 95.6186,
      activeRigs: 4,
      openReports: 19,
      criticalAlerts: 2,
      safetyHealthScore: 79.5,
    ),
    const SiteModel(
      id: 'SITE-03',
      name: 'Moran Drilling Unit',
      code: 'MRN-DRL',
      type: 'Deep Well Exploration & Rig Site',
      latitude: 27.1850,
      longitude: 94.9310,
      activeRigs: 6,
      openReports: 27,
      criticalAlerts: 4,
      safetyHealthScore: 76.0,
    ),
    const SiteModel(
      id: 'SITE-04',
      name: 'Naharkatiya Gathering Station',
      code: 'NHK-GGS',
      type: 'Group Gathering & Separation Facility',
      latitude: 27.2798,
      longitude: 95.3411,
      activeRigs: 3,
      openReports: 14,
      criticalAlerts: 1,
      safetyHealthScore: 88.0,
    ),
    const SiteModel(
      id: 'SITE-05',
      name: 'Jorhat Crude Terminal',
      code: 'JRH-TRM',
      type: 'Pipeline Pump & Tank Farm Terminal',
      latitude: 26.7509,
      longitude: 94.2037,
      activeRigs: 2,
      openReports: 11,
      criticalAlerts: 0,
      safetyHealthScore: 91.5,
    ),
    const SiteModel(
      id: 'SITE-06',
      name: 'Dibrugarh Logistics Base',
      code: 'DBR-LOG',
      type: 'Heavy Equipment & Material Yard',
      latitude: 27.4728,
      longitude: 94.9120,
      activeRigs: 1,
      openReports: 8,
      criticalAlerts: 0,
      safetyHealthScore: 89.0,
    ),
  ];
});

// Audit Logs Provider
final auditLogsProvider = Provider<List<AuditLogModel>>((ref) {
  return [
    AuditLogModel(
      id: 'AUD-901',
      user: 'Pranab Jyoti Baruah (OIL-EMP-2491)',
      role: 'Safety Officer',
      action: 'HUMAN_FEEDBACK_SUBMITTED',
      target: 'Report #OIL-2026-00428',
      details: 'Confirmed SIF classification CRITICAL for Separator V-102 confined entry.',
      timestamp: DateTime.now().subtract(const Duration(minutes: 40)),
    ),
    AuditLogModel(
      id: 'AUD-902',
      user: 'Biren Gogoi (OIL-EMP-1823)',
      role: 'Site Supervisor',
      action: 'CORRECTIVE_ACTION_PROGRESS_UPDATE',
      target: 'Action #ACT-OIL-1082',
      details: 'Updated progress to 65%: Gas test protocol briefed to contractor crew.',
      timestamp: DateTime.now().subtract(const Duration(hours: 2)),
    ),
    AuditLogModel(
      id: 'AUD-903',
      user: 'System Automated Service',
      role: 'SIF-Sentinel-Daemon',
      action: 'SCHEDULED_ANALYTICS_AGGREGATION',
      target: 'OIL Enterprise Safety Score',
      details: 'Recomputed aggregate risk index across 6 operational sites: Score 82/100.',
      timestamp: DateTime.now().subtract(const Duration(hours: 6)),
    ),
    AuditLogModel(
      id: 'AUD-904',
      user: 'Dr. Ranjit Saikia (OIL-EMP-0912)',
      role: 'Safety Manager',
      action: 'EMERGING_RISK_BROADCAST',
      target: 'Moran Drilling Unit',
      details: 'Issued site-wide LOTO compliance directive following +32% precursor surge.',
      timestamp: DateTime.now().subtract(const Duration(hours: 12)),
    ),
  ];
});
