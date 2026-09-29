import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../shared/widgets/oil_header.dart';
import '../../../shared/widgets/enterprise_card.dart';
import 'site_safety_map_screen.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  String _selectedTimeRange = '30 Days';
  final List<String> _timeRanges = const ['7 Days', '30 Days', '90 Days', 'YTD 2026'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: OilHeader(
        title: 'Safety Analytics',
        subtitle: 'Enterprise SIF Metrics & Precursor Intelligence',
        actions: [
          IconButton(
            tooltip: 'Site Geospatial Map',
            icon: const Icon(Icons.map_outlined, color: AppColors.primaryRed),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (ctx) => const SiteSafetyMapScreen()),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(left: 14, right: 14, top: 12, bottom: 28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Time Range Filter Bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  const Icon(Icons.calendar_today_outlined, size: 15, color: AppColors.textTertiary),
                  const SizedBox(width: 8),
                  Text('Time Horizon:', style: AppTypography.caption.copyWith(fontWeight: FontWeight.w700)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: _timeRanges.map((range) {
                          final isSelected = _selectedTimeRange == range;
                          return Padding(
                            padding: const EdgeInsets.only(right: 6),
                            child: ChoiceChip(
                              label: Text(
                                range,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
                                  color: isSelected ? Colors.white : AppColors.textPrimary,
                                ),
                              ),
                              selected: isSelected,
                              selectedColor: AppColors.primaryRed,
                              backgroundColor: AppColors.surfaceSecondary,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
                              visualDensity: VisualDensity.compact,
                              onSelected: (selected) {
                                if (selected) setState(() => _selectedTimeRange = range);
                              },
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Map Quick Action Callout
            EnterpriseCard(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (ctx) => const SiteSafetyMapScreen()),
                );
              },
              backgroundColor: AppColors.primaryBlack,
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primaryRed,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Icon(Icons.location_searching_rounded, color: Colors.white, size: 20),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Geospatial Site Safety Map',
                          style: AppTypography.bodyMedium.copyWith(color: Colors.white, fontWeight: FontWeight.w700),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                        Text(
                          'View upstream rigs & precursor heatmaps across Upper Assam Basin',
                          style: AppTypography.caption.copyWith(color: const Color(0xFFD1D5DB)),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(Icons.chevron_right, color: Colors.white70, size: 20),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // SIF Precursors by Month Bar Chart
            EnterpriseCard(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          'Total Observations vs SIF Precursors',
                          style: AppTypography.sectionTitle.copyWith(fontSize: 15),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(color: AppColors.surfaceSecondary, borderRadius: BorderRadius.circular(4)),
                        child: Text(_selectedTimeRange, style: AppTypography.caption.copyWith(fontSize: 10.5, fontWeight: FontWeight.w700)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  SizedBox(
                    height: 180,
                    child: BarChart(
                      BarChartData(
                        alignment: BarChartAlignment.spaceAround,
                        maxY: 45,
                        barTouchData: BarTouchData(enabled: true),
                        titlesData: FlTitlesData(
                          show: true,
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 24,
                              getTitlesWidget: (val, meta) {
                                final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun'];
                                final idx = val.toInt();
                                if (idx >= 0 && idx < months.length) {
                                  return Padding(
                                    padding: const EdgeInsets.only(top: 4),
                                    child: Text(months[idx], style: AppTypography.caption.copyWith(fontSize: 9.5)),
                                  );
                                }
                                return const SizedBox();
                              },
                            ),
                          ),
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 22,
                              interval: 10,
                              getTitlesWidget: (val, meta) => Text(
                                val.toInt().toString(),
                                style: AppTypography.caption.copyWith(color: AppColors.textTertiary, fontSize: 9.5),
                              ),
                            ),
                          ),
                          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        ),
                        gridData: const FlGridData(show: false),
                        borderData: FlBorderData(show: false),
                        barGroups: [
                          _buildBarGroup(0, 32, 9),
                          _buildBarGroup(1, 38, 12),
                          _buildBarGroup(2, 35, 11),
                          _buildBarGroup(3, 44, 18),
                          _buildBarGroup(4, 39, 14),
                          _buildBarGroup(5, 41, 15),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 12,
                    runSpacing: 4,
                    children: [
                      _buildLegendDot(AppColors.primaryBlack, 'Total Observations'),
                      _buildLegendDot(AppColors.primaryRed, 'SIF Precursors Detected'),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // SIF POTENTIAL BY ACTIVITY RANKING TABLE
            EnterpriseCard(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          'SIF Precursor Density by Activity',
                          style: AppTypography.sectionTitle.copyWith(fontSize: 15),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(color: AppColors.criticalBg, borderRadius: BorderRadius.circular(4)),
                        child: Text('Ranked by Density %', style: TextStyle(fontSize: 10, color: AppColors.critical, fontWeight: FontWeight.w700)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Identifies high-consequence operations regardless of gross observation volume.',
                    style: AppTypography.caption.copyWith(color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 14),

                  _buildActivityRankingRow('Confined Space Vessel Entry', 48, 36, 75.0, AppColors.critical, Icons.meeting_room_outlined),
                  _buildActivityRankingRow('Well Operations & Workover', 68, 42, 61.8, AppColors.critical, Icons.oil_barrel_outlined),
                  _buildActivityRankingRow('Working at Height (>1.8m)', 58, 26, 44.8, AppColors.high, Icons.height_outlined),
                  _buildActivityRankingRow('Electrical & Mechanical Maintenance', 124, 52, 41.9, AppColors.high, Icons.build_outlined),
                  _buildActivityRankingRow('Rigging & Heavy Lifting Operations', 72, 28, 38.9, AppColors.high, Icons.forklift),
                  _buildActivityRankingRow('Hot Work & Spark Operations', 64, 22, 34.4, AppColors.medium, Icons.local_fire_department_outlined),
                  _buildActivityRankingRow('Pipeline Pigging & Flange Work', 86, 21, 24.4, AppColors.medium, Icons.timeline_outlined),
                  _buildActivityRankingRow('Vehicle Transit & Heavy Hauling', 92, 11, 12.0, AppColors.low, Icons.local_shipping_outlined),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // Hazard Category Breakdown
            EnterpriseCard(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Hazard Taxonomy Distribution', style: AppTypography.sectionTitle.copyWith(fontSize: 15)),
                  const SizedBox(height: 4),
                  Text('Distribution across 246 confirmed SIF precursors', style: AppTypography.caption.copyWith(color: AppColors.textSecondary)),
                  const SizedBox(height: 12),
                  _buildHazardProgressRow('Hazardous Energy (LOTO & Pressurized)', 0.28, '28% (69 SIF)', AppColors.critical),
                  _buildHazardProgressRow('Working at Height & Mast Scaffolding', 0.21, '21% (52 SIF)', AppColors.high),
                  _buildHazardProgressRow('Confined Space & Gas Exposure (H2S/LEL)', 0.19, '19% (47 SIF)', const Color(0xFFC2410C)),
                  _buildHazardProgressRow('Line of Fire & Suspended Mechanical Loads', 0.14, '14% (34 SIF)', AppColors.medium),
                  _buildHazardProgressRow('Work Authorisation & Isolation Bypassing', 0.11, '11% (27 SIF)', AppColors.info),
                  _buildHazardProgressRow('Hot Work & Flammable Vapor Controls', 0.07, '7% (17 SIF)', AppColors.low),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // Operational Site Risk Matrix
            EnterpriseCard(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          'Site Risk Intelligence Matrix',
                          style: AppTypography.sectionTitle.copyWith(fontSize: 15),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(color: AppColors.surfaceSecondary, borderRadius: BorderRadius.circular(4)),
                        child: Text('6 Sites Tracked', style: AppTypography.caption.copyWith(fontSize: 10.5, fontWeight: FontWeight.w700)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text('Multi-variable risk ranking including barrier failures and action backlog.', style: AppTypography.caption.copyWith(color: AppColors.textSecondary)),
                  const SizedBox(height: 12),

                  _buildSiteMatrixCard(
                    siteName: 'Moran Drilling Unit',
                    totalReports: 184,
                    sifPrecursors: 62,
                    sifDensity: '33.7%',
                    criticalCount: 14,
                    openBacklog: 12,
                    statusColor: AppColors.critical,
                  ),
                  const SizedBox(height: 8),
                  _buildSiteMatrixCard(
                    siteName: 'Naharkatiya Gathering Station',
                    totalReports: 228,
                    sifPrecursors: 54,
                    sifDensity: '23.7%',
                    criticalCount: 7,
                    openBacklog: 9,
                    statusColor: AppColors.high,
                  ),
                  const SizedBox(height: 8),
                  _buildSiteMatrixCard(
                    siteName: 'Digboi Oil Field Operations',
                    totalReports: 198,
                    sifPrecursors: 41,
                    sifDensity: '20.7%',
                    criticalCount: 4,
                    openBacklog: 8,
                    statusColor: AppColors.high,
                  ),
                  const SizedBox(height: 8),
                  _buildSiteMatrixCard(
                    siteName: 'Jorhat Exploration Basin',
                    totalReports: 142,
                    sifPrecursors: 22,
                    sifDensity: '15.5%',
                    criticalCount: 1,
                    openBacklog: 5,
                    statusColor: AppColors.medium,
                  ),
                  const SizedBox(height: 8),
                  _buildSiteMatrixCard(
                    siteName: 'Duliajan Main Complex',
                    totalReports: 412,
                    sifPrecursors: 58,
                    sifDensity: '14.1%',
                    criticalCount: 1,
                    openBacklog: 6,
                    statusColor: AppColors.medium,
                  ),
                  const SizedBox(height: 8),
                  _buildSiteMatrixCard(
                    siteName: 'Numaligarh Refuelling & Terminal',
                    totalReports: 120,
                    sifPrecursors: 9,
                    sifDensity: '7.5%',
                    criticalCount: 0,
                    openBacklog: 2,
                    statusColor: AppColors.low,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  static BarChartGroupData _buildBarGroup(int x, double total, double sif) {
    return BarChartGroupData(
      x: x,
      barsSpace: 3,
      barRods: [
        BarChartRodData(
          toY: total,
          color: AppColors.primaryBlack,
          width: 8.5,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(2.5)),
        ),
        BarChartRodData(
          toY: sif,
          color: AppColors.primaryRed,
          width: 8.5,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(2.5)),
        ),
      ],
    );
  }

  Widget _buildLegendDot(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 7, height: 7, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 4),
        Text(label, style: AppTypography.caption.copyWith(fontSize: 10.5)),
      ],
    );
  }

  Widget _buildActivityRankingRow(
    String activity,
    int totalReports,
    int sifCount,
    double density,
    Color color,
    IconData icon,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Container(
        padding: const EdgeInsets.all(10),
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
                Icon(icon, size: 16, color: AppColors.textTertiary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    activity,
                    style: AppTypography.bodySmall.copyWith(fontWeight: FontWeight.w700),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    '${density.toStringAsFixed(1)}% SIF',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: color),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(3),
                    child: LinearProgressIndicator(
                      value: (density / 100.0),
                      minHeight: 5,
                      backgroundColor: AppColors.surfaceSecondary,
                      valueColor: AlwaysStoppedAnimation<Color>(color),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  '$sifCount SIF / $totalReports Reports',
                  style: AppTypography.caption.copyWith(color: AppColors.textSecondary, fontSize: 10),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHazardProgressRow(String label, double val, String percent, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  label,
                  style: AppTypography.bodySmall.copyWith(fontWeight: FontWeight.w600),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Text(percent, style: AppTypography.bodySmall.copyWith(fontWeight: FontWeight.w700, color: color)),
            ],
          ),
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: LinearProgressIndicator(
              value: val,
              minHeight: 6,
              backgroundColor: AppColors.surfaceSecondary,
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSiteMatrixCard({
    required String siteName,
    required int totalReports,
    required int sifPrecursors,
    required String sifDensity,
    required int criticalCount,
    required int openBacklog,
    required Color statusColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 38,
            decoration: BoxDecoration(
              color: statusColor,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  siteName,
                  style: AppTypography.bodySmall.copyWith(fontWeight: FontWeight.w700),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  '$totalReports Reports • $criticalCount Critical • $openBacklog Open Actions',
                  style: AppTypography.caption.copyWith(color: AppColors.textSecondary, fontSize: 10),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                sifDensity,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: statusColor,
                ),
              ),
              Text(
                '$sifPrecursors SIF',
                style: AppTypography.caption.copyWith(color: AppColors.textTertiary, fontSize: 9.5, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

