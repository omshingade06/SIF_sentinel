class AuditLogModel {
  final String id;
  final String user;
  final String role;
  final String action;
  final String target;
  final String details;
  final DateTime timestamp;
  final String ipAddress;

  const AuditLogModel({
    required this.id,
    required this.user,
    required this.role,
    required this.action,
    required this.target,
    required this.details,
    required this.timestamp,
    this.ipAddress = '10.128.42.15 (OIL-INTRANET)',
  });
}
