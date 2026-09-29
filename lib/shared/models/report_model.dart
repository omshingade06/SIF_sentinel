import 'sif_analysis_model.dart';

enum ReportStatus {
  newReport,
  aiAnalyzed,
  underReview,
  actionAssigned,
  actionInProgress,
  resolved,
  closed;

  String get label {
    switch (this) {
      case ReportStatus.newReport:
        return 'New';
      case ReportStatus.aiAnalyzed:
        return 'AI Analyzed';
      case ReportStatus.underReview:
        return 'Under Review';
      case ReportStatus.actionAssigned:
        return 'Action Assigned';
      case ReportStatus.actionInProgress:
        return 'Action In Progress';
      case ReportStatus.resolved:
        return 'Resolved';
      case ReportStatus.closed:
        return 'Closed';
    }
  }
}

class ReportComment {
  final String id;
  final String authorName;
  final String authorRole;
  final String message;
  final DateTime createdAt;

  const ReportComment({
    required this.id,
    required this.authorName,
    required this.authorRole,
    required this.message,
    required this.createdAt,
  });
}

class ReportAuditEntry {
  final String action;
  final String performedBy;
  final String details;
  final DateTime timestamp;

  const ReportAuditEntry({
    required this.action,
    required this.performedBy,
    required this.details,
    required this.timestamp,
  });
}

class ReportModel {
  final String id; // e.g. OIL-2026-00428
  final String reportType; // Near Miss, Unsafe Condition, Unsafe Act, Safety Observation
  final String observationText;
  final String site;
  final String department;
  final String workActivity;
  final String equipment;
  final String submittedByName;
  final String submittedByRole;
  final DateTime submittedAt;
  final ReportStatus status;
  final SifAnalysisModel? sifAnalysis;
  final List<String> photoUrls;
  final List<ReportComment> comments;
  final List<ReportAuditEntry> auditTrail;
  final bool isSynced;
  final double? latitude;
  final double? longitude;

  const ReportModel({
    required this.id,
    required this.reportType,
    required this.observationText,
    required this.site,
    required this.department,
    required this.workActivity,
    required this.equipment,
    required this.submittedByName,
    required this.submittedByRole,
    required this.submittedAt,
    this.status = ReportStatus.aiAnalyzed,
    this.sifAnalysis,
    this.photoUrls = const [],
    this.comments = const [],
    this.auditTrail = const [],
    this.isSynced = true,
    this.latitude,
    this.longitude,
  });

  ReportModel copyWith({
    String? reportType,
    String? observationText,
    String? site,
    String? department,
    String? workActivity,
    String? equipment,
    ReportStatus? status,
    SifAnalysisModel? sifAnalysis,
    List<String>? photoUrls,
    List<ReportComment>? comments,
    List<ReportAuditEntry>? auditTrail,
    bool? isSynced,
    double? latitude,
    double? longitude,
  }) {
    return ReportModel(
      id: id,
      reportType: reportType ?? this.reportType,
      observationText: observationText ?? this.observationText,
      site: site ?? this.site,
      department: department ?? this.department,
      workActivity: workActivity ?? this.workActivity,
      equipment: equipment ?? this.equipment,
      submittedByName: submittedByName,
      submittedByRole: submittedByRole,
      submittedAt: submittedAt,
      status: status ?? this.status,
      sifAnalysis: sifAnalysis ?? this.sifAnalysis,
      photoUrls: photoUrls ?? this.photoUrls,
      comments: comments ?? this.comments,
      auditTrail: auditTrail ?? this.auditTrail,
      isSynced: isSynced ?? this.isSynced,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
    );
  }
}
