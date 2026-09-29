enum ActionStatus {
  assigned,
  inProgress,
  pendingVerification,
  completed,
  overdue;

  String get label {
    switch (this) {
      case ActionStatus.assigned:
        return 'Assigned';
      case ActionStatus.inProgress:
        return 'In Progress';
      case ActionStatus.pendingVerification:
        return 'Pending Verification';
      case ActionStatus.completed:
        return 'Completed';
      case ActionStatus.overdue:
        return 'Overdue';
    }
  }
}

enum ActionPriority {
  critical,
  high,
  medium,
  low;

  String get label {
    switch (this) {
      case ActionPriority.critical:
        return 'Critical';
      case ActionPriority.high:
        return 'High';
      case ActionPriority.medium:
        return 'Medium';
      case ActionPriority.low:
        return 'Low';
    }
  }
}

class CorrectiveActionModel {
  final String id;
  final String reportId;
  final String title;
  final String description;
  final String assignedToName;
  final String assignedToRole;
  final String site;
  final ActionPriority priority;
  final ActionStatus status;
  final double progress; // 0.0 to 1.0
  final DateTime dueDate;
  final DateTime createdAt;
  final String? closureVerificationNotes;
  final String? verifiedByName;
  final DateTime? completedAt;

  const CorrectiveActionModel({
    required this.id,
    required this.reportId,
    required this.title,
    required this.description,
    required this.assignedToName,
    required this.assignedToRole,
    required this.site,
    required this.priority,
    required this.status,
    required this.progress,
    required this.dueDate,
    required this.createdAt,
    this.closureVerificationNotes,
    this.verifiedByName,
    this.completedAt,
  });

  CorrectiveActionModel copyWith({
    String? title,
    String? description,
    String? assignedToName,
    String? assignedToRole,
    String? site,
    ActionPriority? priority,
    ActionStatus? status,
    double? progress,
    DateTime? dueDate,
    String? closureVerificationNotes,
    String? verifiedByName,
    DateTime? completedAt,
  }) {
    return CorrectiveActionModel(
      id: id,
      reportId: reportId,
      title: title ?? this.title,
      description: description ?? this.description,
      assignedToName: assignedToName ?? this.assignedToName,
      assignedToRole: assignedToRole ?? this.assignedToRole,
      site: site ?? this.site,
      priority: priority ?? this.priority,
      status: status ?? this.status,
      progress: progress ?? this.progress,
      dueDate: dueDate ?? this.dueDate,
      createdAt: createdAt,
      closureVerificationNotes:
          closureVerificationNotes ?? this.closureVerificationNotes,
      verifiedByName: verifiedByName ?? this.verifiedByName,
      completedAt: completedAt ?? this.completedAt,
    );
  }
}
