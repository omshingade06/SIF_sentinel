class SiteModel {
  final String id;
  final String name;
  final String code;
  final String type;
  final double latitude;
  final double longitude;
  final int activeRigs;
  final int openReports;
  final int criticalAlerts;
  final double safetyHealthScore; // e.g. 84.5

  const SiteModel({
    required this.id,
    required this.name,
    required this.code,
    required this.type,
    required this.latitude,
    required this.longitude,
    required this.activeRigs,
    required this.openReports,
    required this.criticalAlerts,
    this.safetyHealthScore = 82.0,
  });
}
