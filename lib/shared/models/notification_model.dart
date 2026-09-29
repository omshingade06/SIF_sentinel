import 'sif_analysis_model.dart';

enum NotificationType {
  criticalSifAlert,
  actionOverdue,
  emergingRisk,
  aiModelUpdate,
  reportReviewed,
}

class NotificationModel {
  final String id;
  final String title;
  final String message;
  final NotificationType type;
  final SifPotential? sifPotential;
  final String? relatedReportId;
  final DateTime timestamp;
  final bool isRead;

  const NotificationModel({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    this.sifPotential,
    this.relatedReportId,
    required this.timestamp,
    this.isRead = false,
  });

  NotificationModel copyWith({bool? isRead}) {
    return NotificationModel(
      id: id,
      title: title,
      message: message,
      type: type,
      sifPotential: sifPotential,
      relatedReportId: relatedReportId,
      timestamp: timestamp,
      isRead: isRead ?? this.isRead,
    );
  }
}
