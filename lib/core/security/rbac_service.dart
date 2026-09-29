/// Standard Petroleum Industry / OIL User Roles
enum UserRole {
  engineer('engineer', 'Engineer', 'Operations & Facilities Engineer'),
  siteSupervisor('site_supervisor', 'Site / Rig Supervisor', 'Upstream Drilling & Rig Site Supervisor'),
  hseOfficer('hse_officer', 'HSE Officer', 'Field Health, Safety & Environment Officer'),
  hseDirectorate('hse_manager', 'HSE Directorate / Manager', 'Corporate HSE Management & Executive Oversight'),
  administrator('administrator', 'Administrator', 'Enterprise IT & Safety System Administrator');

  final String key;
  final String displayName;
  final String description;

  const UserRole(this.key, this.displayName, this.description);

  /// Strict validation of supported roles in Firestore
  static bool isValidRole(String? roleStr) {
    return tryFromString(roleStr) != null;
  }

  /// Safe parse that returns null if the role string is null, empty, or not recognized
  static UserRole? tryFromString(String? roleStr) {
    if (roleStr == null || roleStr.trim().isEmpty) return null;
    final clean = roleStr.trim().toLowerCase().replaceAll('-', '_').replaceAll(' ', '_');

    // Direct key matches
    if (clean == 'engineer' || clean.contains('engineer')) return UserRole.engineer;
    if (clean == 'site_supervisor' || clean == 'supervisor' || clean.contains('supervisor')) return UserRole.siteSupervisor;
    if (clean == 'hse_officer' || clean.contains('officer')) return UserRole.hseOfficer;
    if (clean == 'hse_manager' || clean == 'hse_director' || clean == 'hse_directorate' || clean.contains('director') || clean.contains('manager')) {
      return UserRole.hseDirectorate;
    }
    if (clean == 'administrator' || clean == 'admin' || clean.contains('admin')) return UserRole.administrator;

    for (final role in UserRole.values) {
      if (role.key.toLowerCase() == clean ||
          role.displayName.toLowerCase().replaceAll(' ', '_') == clean ||
          role.name.toLowerCase() == clean) {
        return role;
      }
    }
    return null;
  }

  static UserRole fromString(String roleStr) {
    return tryFromString(roleStr) ?? UserRole.hseOfficer;
  }
}

/// Granular Security Permissions for SIF Sentinel RBAC Engine
enum Permission {
  // --- Dashboard & Navigation ---
  viewEngineerDashboard('View Engineer Operational Dashboard'),
  viewSiteDashboard('View Rig / Site Supervisor Dashboard'),
  viewHseDashboard('View HSE Officer Operational Dashboard'),
  viewExecutiveDashboard('View Executive HSE Directorate Dashboard'),
  viewAdminDashboard('View System Administration Dashboard'),

  // --- Observation & Incident Reporting ---
  createObservation('Create Field Safety Observations'),
  submitUaReport('Submit Unsafe Act (UA) Reports'),
  submitUcReport('Submit Unsafe Condition (UC) Reports'),
  submitNearMissReport('Submit Near-Miss Reports'),
  submitIncidentReport('Submit Safety Incident Reports'),
  uploadEvidence('Upload Photographic & Document Evidence'),
  useVoiceInput('Use Industrial Voice-to-Text Input'),
  viewOwnReports('View Own Submitted Reports'),
  viewSiteReports('View Site-Level Reports'),
  viewAllReports('View Organization-Wide Reports'),
  searchFilterReports('Search & Filter Reports'),
  reviewEvidence('Review Field Evidence & Attachments'),

  // --- AI Insights & Human-in-the-Loop Review ---
  viewAiInsights('View AI SIF Precursor Intelligence'),
  viewAiExplanation('View Explainable AI Reasoning & Evidence'),
  overrideAiClassification('Human-in-the-Loop AI Classification Override'),
  modifyLifeSavingRule('Modify Assigned IOGP Life-Saving Rule'),
  modifyDetectedHazards('Add or Remove Detected Hazards'),
  editAiExplanation('Edit AI Rationale & Explanation Notes'),
  submitAiFeedback('Submit Feedback to Train Model'),

  // --- Corrective Actions ---
  viewAssignedActions('View Assigned Corrective Actions'),
  viewSiteActions('View Site Corrective Actions'),
  viewAllActions('View Organization-Wide Actions'),
  createAction('Create Corrective Actions'),
  assignAction('Assign Corrective Actions to Personnel'),
  updateActionProgress('Update Action Status & Upload Evidence'),
  verifyActionCompletion('Verify & Close Corrective Actions'),
  monitorActionBacklog('Monitor Corrective Action Backlog & KPIs'),

  // --- Analytics & Intelligence ---
  viewSiteAnalytics('View Site-Specific Analytics'),
  viewOrgAnalytics('View Multi-Site Organization Analytics'),
  viewSifTrends('View SIF Trend & Density Charts'),
  viewLsrTrends('View Life-Saving Rule Compliance Trends'),
  viewBarrierFailures('View Barrier Degradation Analytics'),
  viewPrecursorPatterns('View Recurring Precursor Patterns'),
  compareSites('Compare Site SIF Performance & Risk Density'),
  viewHighPriorityAlerts('View High-Priority Safety Alerts'),
  accessBatchIngestion('Upload Bulk Safety Datasets & Run Batch NLP'),
  exportData('Export Safety Data & Analytical Reports'),

  // --- Administration & System Governance ---
  manageUsers('Manage Users (Create, Deactivate, Activate)'),
  assignRoles('Assign User Roles & Site Scopes'),
  configureRbac('Configure Roles & Security Permissions'),
  configureTaxonomy('Configure LSR Taxonomy & Domain Ontology'),
  configureIntegrations('Configure API & Enterprise Integrations'),
  viewAuditLogs('Inspect Immutable Security & Override Audit Logs'),
  manageSystemSettings('Configure System Security & Session Policies');

  final String description;
  const Permission(this.description);
}

/// Enterprise Role-Based Access Control (RBAC) Engine
class RbacService {
  RbacService._();

  static const Map<UserRole, Set<Permission>> _rolePermissions = {
    // 1. ENGINEER
    UserRole.engineer: {
      Permission.viewEngineerDashboard,
      Permission.createObservation,
      Permission.submitUaReport,
      Permission.submitUcReport,
      Permission.submitNearMissReport,
      Permission.submitIncidentReport,
      Permission.uploadEvidence,
      Permission.useVoiceInput,
      Permission.viewOwnReports,
      Permission.searchFilterReports,
      Permission.viewAiInsights,
      Permission.viewAiExplanation,
      Permission.viewAssignedActions,
      Permission.updateActionProgress,
    },

    // 2. SITE / RIG SUPERVISOR
    UserRole.siteSupervisor: {
      Permission.viewSiteDashboard,
      Permission.createObservation,
      Permission.submitUaReport,
      Permission.submitUcReport,
      Permission.submitNearMissReport,
      Permission.submitIncidentReport,
      Permission.uploadEvidence,
      Permission.useVoiceInput,
      Permission.viewOwnReports,
      Permission.viewSiteReports,
      Permission.searchFilterReports,
      Permission.reviewEvidence,
      Permission.viewAiInsights,
      Permission.viewAiExplanation,
      Permission.viewAssignedActions,
      Permission.viewSiteActions,
      Permission.updateActionProgress,
      Permission.viewSiteAnalytics,
      Permission.exportData,
    },

    // 3. HSE OFFICER (Primary Operational Review Role)
    UserRole.hseOfficer: {
      Permission.viewHseDashboard,
      Permission.createObservation,
      Permission.submitUaReport,
      Permission.submitUcReport,
      Permission.submitNearMissReport,
      Permission.submitIncidentReport,
      Permission.uploadEvidence,
      Permission.useVoiceInput,
      Permission.viewOwnReports,
      Permission.viewSiteReports,
      Permission.viewAllReports,
      Permission.searchFilterReports,
      Permission.reviewEvidence,
      Permission.viewAiInsights,
      Permission.viewAiExplanation,
      Permission.overrideAiClassification,
      Permission.modifyLifeSavingRule,
      Permission.modifyDetectedHazards,
      Permission.editAiExplanation,
      Permission.submitAiFeedback,
      Permission.viewAssignedActions,
      Permission.viewSiteActions,
      Permission.viewAllActions,
      Permission.createAction,
      Permission.assignAction,
      Permission.updateActionProgress,
      Permission.verifyActionCompletion,
      Permission.viewSiteAnalytics,
      Permission.viewOrgAnalytics,
      Permission.viewSifTrends,
      Permission.viewLsrTrends,
      Permission.viewBarrierFailures,
      Permission.viewPrecursorPatterns,
      Permission.viewHighPriorityAlerts,
      Permission.exportData,
    },

    // 4. HSE DIRECTORATE / MANAGER (Organization-Level Executive Intelligence)
    UserRole.hseDirectorate: {
      Permission.viewExecutiveDashboard,
      Permission.viewOwnReports,
      Permission.viewSiteReports,
      Permission.viewAllReports,
      Permission.searchFilterReports,
      Permission.reviewEvidence,
      Permission.viewAiInsights,
      Permission.viewAiExplanation,
      Permission.viewAssignedActions,
      Permission.viewSiteActions,
      Permission.viewAllActions,
      Permission.monitorActionBacklog,
      Permission.viewSiteAnalytics,
      Permission.viewOrgAnalytics,
      Permission.viewSifTrends,
      Permission.viewLsrTrends,
      Permission.viewBarrierFailures,
      Permission.viewPrecursorPatterns,
      Permission.compareSites,
      Permission.viewHighPriorityAlerts,
      Permission.viewAuditLogs,
      Permission.exportData,
    },

    // 5. ADMINISTRATOR (System Governance & Security Management)
    UserRole.administrator: {
      Permission.viewAdminDashboard,
      Permission.viewOwnReports,
      Permission.viewSiteReports,
      Permission.viewAllReports,
      Permission.searchFilterReports,
      Permission.reviewEvidence,
      Permission.viewAiInsights,
      Permission.viewAiExplanation,
      Permission.overrideAiClassification,
      Permission.modifyLifeSavingRule,
      Permission.modifyDetectedHazards,
      Permission.viewAssignedActions,
      Permission.viewSiteActions,
      Permission.viewAllActions,
      Permission.createAction,
      Permission.assignAction,
      Permission.updateActionProgress,
      Permission.verifyActionCompletion,
      Permission.monitorActionBacklog,
      Permission.viewSiteAnalytics,
      Permission.viewOrgAnalytics,
      Permission.viewSifTrends,
      Permission.viewLsrTrends,
      Permission.viewBarrierFailures,
      Permission.viewPrecursorPatterns,
      Permission.compareSites,
      Permission.viewHighPriorityAlerts,
      Permission.manageUsers,
      Permission.assignRoles,
      Permission.configureRbac,
      Permission.configureTaxonomy,
      Permission.configureIntegrations,
      Permission.viewAuditLogs,
      Permission.manageSystemSettings,
      Permission.exportData,
    },
  };

  /// Check if a given role has a specific permission
  static bool hasPermission(UserRole role, Permission permission) {
    final permissions = _rolePermissions[role] ?? {};
    return permissions.contains(permission);
  }

  /// Check if a role has all required permissions
  static bool hasAllPermissions(UserRole role, List<Permission> permissions) {
    return permissions.every((p) => hasPermission(role, p));
  }

  /// Get list of permissions for a role
  static Set<Permission> getPermissionsForRole(UserRole role) {
    return _rolePermissions[role] ?? {};
  }

  /// Formatted permission matrix for administrative inspection
  static Map<UserRole, Set<Permission>> getFullMatrix() => Map.unmodifiable(_rolePermissions);
}
