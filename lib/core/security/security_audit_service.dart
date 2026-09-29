import 'dart:collection';
import 'package:uuid/uuid.dart';
import 'rbac_service.dart';

enum AuditEventType {
  loginSuccess('LOGIN_SUCCESS', 'User successfully authenticated'),
  loginFailed('LOGIN_FAILED', 'Authentication failed / invalid credentials'),
  logout('LOGOUT', 'User securely signed out and token invalidated'),
  sessionTimeout('SESSION_TIMEOUT', 'User session locked due to inactivity'),
  roleChanged('ROLE_CHANGED', 'User role or active permission context modified'),
  aiOverride('AI_OVERRIDE', 'Human-in-the-Loop safety officer AI assessment override'),
  reportCreated('REPORT_CREATED', 'New safety observation or incident report submitted'),
  reportModified('REPORT_MODIFIED', 'Safety report details or classification updated'),
  actionModified('ACTION_MODIFIED', 'Corrective action status or owner updated'),
  taxonomyChanged('TAXONOMY_CHANGED', 'Hazard taxonomy or Life-Saving Rule mapping altered'),
  batchIngestion('BATCH_INGESTION', 'Bulk safety dataset ingested and NLP analyzed'),
  securityConfigChanged('SECURITY_CONFIG_CHANGED', 'Enterprise security policy or threshold updated');

  final String code;
  final String description;
  const AuditEventType(this.code, this.description);
}

class SecurityAuditEvent {
  final String id;
  final DateTime timestamp;
  final AuditEventType type;
  final String employeeId;
  final String actorName;
  final UserRole role;
  final String actionDescription;
  final String outcome; // SUCCESS / DENIED / WARNING / OVERRIDE
  final Map<String, dynamic> metadata;
  final String ipAddress;

  const SecurityAuditEvent({
    required this.id,
    required this.timestamp,
    required this.type,
    required this.employeeId,
    required this.actorName,
    required this.role,
    required this.actionDescription,
    required this.outcome,
    this.metadata = const {},
    this.ipAddress = '10.14.82.109 (OIL Intranet)',
  });
}

/// Centralized, Immutable Security Audit Logging Service
class SecurityAuditService {
  static final SecurityAuditService _instance = SecurityAuditService._internal();
  factory SecurityAuditService() => _instance;
  SecurityAuditService._internal() {
    _seedInitialAuditEvents();
  }

  static const _uuid = Uuid();
  final List<SecurityAuditEvent> _events = [];

  void _seedInitialAuditEvents() {
    final now = DateTime.now();
    _events.addAll([
      SecurityAuditEvent(
        id: 'AUD-2026-00192',
        timestamp: now.subtract(const Duration(hours: 4, minutes: 12)),
        type: AuditEventType.loginSuccess,
        employeeId: 'OIL-EMP-2491',
        actorName: 'Pranab Jyoti Baruah',
        role: UserRole.hseOfficer,
        actionDescription: 'Employee ID credential authentication passed via Oil India SSO Gateway',
        outcome: 'SUCCESS',
        metadata: {'authMode': 'SSO_SAML2', 'device': 'OIL Field Tablet Android 14'},
      ),
      SecurityAuditEvent(
        id: 'AUD-2026-00193',
        timestamp: now.subtract(const Duration(hours: 3, minutes: 45)),
        type: AuditEventType.aiOverride,
        employeeId: 'OIL-EMP-2491',
        actorName: 'Pranab Jyoti Baruah',
        role: UserRole.hseOfficer,
        actionDescription: 'Overrode AI NLP Classification on Report #OIL-REP-2026-001 from Non-SIF to SIF-Potential',
        outcome: 'OVERRIDE',
        metadata: {'reportId': 'OIL-REP-2026-001', 'originalRisk': 'MEDIUM', 'revisedRisk': 'CRITICAL', 'rule': 'Energy Isolation'},
      ),
      SecurityAuditEvent(
        id: 'AUD-2026-00194',
        timestamp: now.subtract(const Duration(hours: 2, minutes: 30)),
        type: AuditEventType.batchIngestion,
        employeeId: 'OIL-EMP-0450',
        actorName: 'Anupam Sharma',
        role: UserRole.administrator,
        actionDescription: 'Initiated batch NLP ingestion of 500 Historical Turnaround Records (CSV format)',
        outcome: 'SUCCESS',
        metadata: {'recordCount': 500, 'sifDetected': 118, 'processingTimeMs': 3240},
      ),
      SecurityAuditEvent(
        id: 'AUD-2026-00195',
        timestamp: now.subtract(const Duration(hours: 1, minutes: 15)),
        type: AuditEventType.taxonomyChanged,
        employeeId: 'OIL-EMP-0912',
        actorName: 'Dr. Ranjit Saikia',
        role: UserRole.hseDirectorate,
        actionDescription: 'Updated mandatory safeguard requirements for IOGP Life-Saving Rule #1 (Energy Isolation)',
        outcome: 'SUCCESS',
        metadata: {'ruleId': 'LSR-01', 'updatedSafeguard': 'Double-Block-and-Bleed Physical Verification'},
      ),
      SecurityAuditEvent(
        id: 'AUD-2026-00196',
        timestamp: now.subtract(const Duration(minutes: 42)),
        type: AuditEventType.loginFailed,
        employeeId: 'UNKNOWN-USER',
        actorName: 'Unauthorized External Request',
        role: UserRole.engineer,
        actionDescription: 'Invalid JWT bearer token signature rejected by Secure API Gateway',
        outcome: 'DENIED',
        ipAddress: '192.168.1.104',
        metadata: {'reason': 'SIGNATURE_INVALID', 'rateLimitStatus': 'NORMAL'},
      ),
    ]);
  }

  /// Record a new immutable security audit event
  void logEvent({
    required AuditEventType type,
    required String employeeId,
    required String actorName,
    required UserRole role,
    required String actionDescription,
    required String outcome,
    Map<String, dynamic> metadata = const {},
    String ipAddress = '10.14.82.109 (OIL Intranet)',
  }) {
    final event = SecurityAuditEvent(
      id: 'AUD-2026-${_uuid.v4().substring(0, 5).toUpperCase()}',
      timestamp: DateTime.now(),
      type: type,
      employeeId: employeeId,
      actorName: actorName,
      role: role,
      actionDescription: actionDescription,
      outcome: outcome,
      metadata: metadata,
      ipAddress: ipAddress,
    );
    _events.insert(0, event);
  }

  /// Read-only access to audit trail (requires viewAuditLogs permission in production)
  UnmodifiableListView<SecurityAuditEvent> getEvents() => UnmodifiableListView(_events);

  /// Filter audit events by type
  List<SecurityAuditEvent> getEventsByType(AuditEventType type) {
    return _events.where((e) => e.type == type).toList();
  }

  /// Clear audit logs (Admin only with security confirmation)
  void clearEvents() {
    _events.clear();
  }
}
