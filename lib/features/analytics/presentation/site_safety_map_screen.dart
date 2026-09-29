import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../shared/models/site_model.dart';
import '../../../shared/widgets/oil_header.dart';
import '../../reports/providers/reports_provider.dart';

class SiteSafetyMapScreen extends ConsumerStatefulWidget {
  const SiteSafetyMapScreen({super.key});

  @override
  ConsumerState<SiteSafetyMapScreen> createState() => _SiteSafetyMapScreenState();
}

class _SiteSafetyMapScreenState extends ConsumerState<SiteSafetyMapScreen> {
  SiteModel? _selectedSite;

  @override
  Widget build(BuildContext context) {
    final sites = ref.watch(sitesProvider);
    _selectedSite ??= sites.first;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const OilHeader(
        title: 'OIL Site Safety Map',
        subtitle: 'Geospatial SIF Hotspot Visualization',
      ),
      body: Column(
        children: [
          // Simulated Interactive Satellite / Vector Map Canvas
          Expanded(
            flex: 5,
            child: Container(
              width: double.infinity,
              color: const Color(0xFF1E293B), // Dark tactical map background
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final mapWidth = constraints.maxWidth;
                  final mapHeight = constraints.maxHeight;

                  return Stack(
                    children: [
                      // Map Grid Lines & Compass
                      Positioned.fill(
                        child: CustomPaint(
                          painter: _MapGridPainter(),
                        ),
                      ),

                      // Header Map Controls
                      Positioned(
                        top: 12,
                        left: 12,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.7),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: Colors.white24),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.layers_outlined, size: 13, color: Colors.white),
                              const SizedBox(width: 5),
                              Text(
                                'UPSTREAM ASSAM ASSET MAP',
                                style: AppTypography.overline.copyWith(color: Colors.white, fontSize: 9.5),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Site Markers plotted proportionally with LayoutBuilder constraints
                      ...sites.map((site) {
                        final isSelected = _selectedSite?.id == site.id;
                        // Proportional latitude & longitude mapping across Assam basin
                        final double topRatio = ((27.50 - site.latitude) / (27.50 - 26.70)).clamp(0.08, 0.90);
                        final double leftRatio = ((site.longitude - 94.10) / (95.70 - 94.10)).clamp(0.08, 0.88);

                        final double topPos = (topRatio * (mapHeight - 75)) + 30;
                        final double leftPos = (leftRatio * (mapWidth - 65)) + 15;

                        Color pinColor = AppColors.low;
                        if (site.criticalAlerts >= 3) {
                          pinColor = AppColors.critical;
                        } else if (site.criticalAlerts >= 1) {
                          pinColor = AppColors.high;
                        }

                        return Positioned(
                          top: topPos,
                          left: leftPos,
                          child: GestureDetector(
                            onTap: () => setState(() => _selectedSite = site),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                AnimatedContainer(
                                  duration: const Duration(milliseconds: 250),
                                  padding: EdgeInsets.all(isSelected ? 5 : 3.5),
                                  decoration: BoxDecoration(
                                    color: pinColor,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Colors.white,
                                      width: isSelected ? 2.2 : 1.2,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: pinColor.withValues(alpha: 0.6),
                                        blurRadius: isSelected ? 10 : 5,
                                        spreadRadius: isSelected ? 2 : 1,
                                      ),
                                    ],
                                  ),
                                  child: Icon(
                                    Icons.oil_barrel_rounded,
                                    size: isSelected ? 16 : 12,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 3),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                                  decoration: BoxDecoration(
                                    color: isSelected ? Colors.black : Colors.black87,
                                    borderRadius: BorderRadius.circular(3),
                                    border: Border.all(
                                      color: isSelected ? AppColors.primaryRed : Colors.transparent,
                                    ),
                                  ),
                                  child: Text(
                                    site.code,
                                    style: AppTypography.overline.copyWith(
                                      color: Colors.white,
                                      fontSize: 8.5,
                                      fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }),
                    ],
                  );
                },
              ),
            ),
          ),

          // Selected Site Intelligence Drawer
          if (_selectedSite != null)
            Expanded(
              flex: 5,
              child: Container(
                color: AppColors.surface,
                padding: const EdgeInsets.all(16),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _selectedSite!.name,
                                  style: AppTypography.headingMedium.copyWith(fontSize: 16),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  _selectedSite!.type,
                                  style: AppTypography.caption,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                            decoration: BoxDecoration(
                              color: _selectedSite!.criticalAlerts > 0 ? AppColors.criticalBg : AppColors.lowBg,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              '${_selectedSite!.criticalAlerts} CRITICAL',
                              style: AppTypography.overline.copyWith(
                                color: _selectedSite!.criticalAlerts > 0 ? AppColors.critical : AppColors.low,
                                fontWeight: FontWeight.w700,
                                fontSize: 9.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: _buildSiteStatBox('Active Rigs', '${_selectedSite!.activeRigs}', Icons.precision_manufacturing),
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: _buildSiteStatBox('Open Reports', '${_selectedSite!.openReports}', Icons.assignment_outlined),
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: _buildSiteStatBox('Health Score', '${_selectedSite!.safetyHealthScore.toInt()}%', Icons.health_and_safety_outlined),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          const Icon(Icons.location_on_outlined, size: 14, color: AppColors.textSecondary),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              'GPS Coordinates: ${_selectedSite!.latitude}° N, ${_selectedSite!.longitude}° E',
                              style: AppTypography.caption.copyWith(color: AppColors.textSecondary, fontSize: 11),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSiteStatBox(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 13, color: AppColors.primaryRed),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  label,
                  style: AppTypography.caption.copyWith(fontSize: 9.5),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              style: AppTypography.bodyLarge.copyWith(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}

class _MapGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF334155)
      ..strokeWidth = 0.6;

    // Draw grid lines
    const double step = 40.0;
    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
