import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../shared/widgets/enterprise_card.dart';

class SifClassificationCard extends StatelessWidget {
  final int totalReports;
  final int sifPotentialReports;
  final int nonSifReports;
  final double sifPercentage;

  const SifClassificationCard({
    super.key,
    this.totalReports = 1284,
    this.sifPotentialReports = 246,
    this.nonSifReports = 1038,
    this.sifPercentage = 19.2,
  });

  @override
  Widget build(BuildContext context) {
    return EnterpriseCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: AppColors.primaryRed.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Icon(Icons.pie_chart_outline_rounded, color: AppColors.primaryRed, size: 18),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'SIF Classification Ratio',
                        style: AppTypography.sectionTitle.copyWith(fontSize: 15),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.surfaceSecondary,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text('AI-Triaged', style: AppTypography.caption.copyWith(fontSize: 10)),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Side-by-side Donut Chart & Breakdown
          Row(
            children: [
              SizedBox(
                width: 100,
                height: 100,
                child: Stack(
                  children: [
                    PieChart(
                      PieChartData(
                        sectionsSpace: 2,
                        centerSpaceRadius: 30,
                        startDegreeOffset: -90,
                        sections: [
                          PieChartSectionData(
                            color: AppColors.primaryRed,
                            value: sifPotentialReports.toDouble(),
                            title: '',
                            radius: 16,
                          ),
                          PieChartSectionData(
                            color: const Color(0xFFE2E8F0),
                            value: nonSifReports.toDouble(),
                            title: '',
                            radius: 14,
                          ),
                        ],
                      ),
                    ),
                    Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '$sifPercentage%',
                            style: AppTypography.caption.copyWith(fontWeight: FontWeight.w900, color: AppColors.primaryRed, fontSize: 13),
                          ),
                          Text(
                            'SIF Rate',
                            style: AppTypography.overline.copyWith(fontSize: 7.5, color: AppColors.textTertiary),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildStatRow('SIF-Potential', '$sifPotentialReports', '$sifPercentage%', AppColors.primaryRed),
                    const SizedBox(height: 8),
                    _buildStatRow('Non-SIF-Potential', '$nonSifReports', '${(100 - sifPercentage).toStringAsFixed(1)}%', AppColors.textSecondary),
                    const Divider(height: 14),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            'Total Triaged Reports',
                            style: AppTypography.caption.copyWith(color: AppColors.textTertiary),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text('$totalReports', style: AppTypography.caption.copyWith(fontWeight: FontWeight.w700)),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          // Disclaimer note per Section 9
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.surfaceSecondary,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline, size: 12, color: AppColors.textTertiary),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'Analytical metric for decision support; not an official OIL benchmark.',
                    style: AppTypography.caption.copyWith(fontSize: 9.5, color: AppColors.textSecondary, fontStyle: FontStyle.italic),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, String count, String percentage, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  label,
                  style: AppTypography.bodySmall.copyWith(fontWeight: FontWeight.w600),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 4),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(count, style: AppTypography.bodySmall.copyWith(fontWeight: FontWeight.w700, color: color)),
            const SizedBox(width: 4),
            Text('($percentage)', style: AppTypography.caption.copyWith(color: AppColors.textTertiary, fontSize: 10.5)),
          ],
        ),
      ],
    );
  }
}
