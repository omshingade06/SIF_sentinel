import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../shared/widgets/enterprise_card.dart';

class SifTrendChart extends StatefulWidget {
  const SifTrendChart({super.key});

  @override
  State<SifTrendChart> createState() => _SifTrendChartState();
}

class _SifTrendChartState extends State<SifTrendChart> {
  String _selectedPeriod = '30D';

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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'SIF Precursor Trend',
                      style: AppTypography.sectionTitle.copyWith(fontSize: 15),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                    Text(
                      'Temporal signals',
                      style: AppTypography.caption.copyWith(fontSize: 10.5),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              // Time Filter Toggle
              Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: AppColors.surfaceSecondary,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: ['7D', '30D', '90D', '1Y'].map((period) {
                    final isSelected = _selectedPeriod == period;
                    return InkWell(
                      onTap: () => setState(() => _selectedPeriod = period),
                      borderRadius: BorderRadius.circular(4),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                        decoration: BoxDecoration(
                          color: isSelected ? Colors.white : Colors.transparent,
                          borderRadius: BorderRadius.circular(4),
                          boxShadow: isSelected
                              ? const [BoxShadow(color: AppColors.shadow, blurRadius: 2)]
                              : null,
                        ),
                        child: Text(
                          period,
                          style: AppTypography.caption.copyWith(
                            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                            color: isSelected ? AppColors.textPrimary : AppColors.textSecondary,
                            fontSize: 10,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Legend with Wrap for responsive line wrapping
          Center(
            child: Wrap(
              alignment: WrapAlignment.center,
              spacing: 10,
              runSpacing: 4,
              children: [
                _buildLegendItem(AppColors.critical, 'Critical'),
                _buildLegendItem(AppColors.high, 'High'),
                _buildLegendItem(AppColors.medium, 'Medium'),
                _buildLegendItem(AppColors.low, 'Low'),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Chart
          SizedBox(
            height: 175,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 10,
                  getDrawingHorizontalLine: (val) => const FlLine(
                    color: AppColors.border,
                    strokeWidth: 1,
                  ),
                ),
                titlesData: FlTitlesData(
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
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 22,
                      interval: 1,
                      getTitlesWidget: (val, meta) {
                        final labels = ['W1', 'W2', 'W3', 'W4', 'W5', 'W6'];
                        final int idx = val.toInt();
                        if (idx >= 0 && idx < labels.length) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              labels[idx],
                              style: AppTypography.caption.copyWith(color: AppColors.textSecondary, fontSize: 9.5),
                            ),
                          );
                        }
                        return const SizedBox();
                      },
                    ),
                  ),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(show: false),
                minX: 0,
                maxX: 5,
                minY: 0,
                maxY: 35,
                lineBarsData: [
                  // Critical Line
                  LineChartBarData(
                    spots: const [
                      FlSpot(0, 4),
                      FlSpot(1, 7),
                      FlSpot(2, 5),
                      FlSpot(3, 9),
                      FlSpot(4, 6),
                      FlSpot(5, 7),
                    ],
                    isCurved: true,
                    color: AppColors.critical,
                    barWidth: 2.5,
                    isStrokeCapRound: true,
                    dotData: const FlDotData(show: true),
                    belowBarData: BarAreaData(
                      show: true,
                      color: AppColors.critical.withValues(alpha: 0.06),
                    ),
                  ),
                  // High Line
                  LineChartBarData(
                    spots: const [
                      FlSpot(0, 12),
                      FlSpot(1, 15),
                      FlSpot(2, 14),
                      FlSpot(3, 19),
                      FlSpot(4, 16),
                      FlSpot(5, 17),
                    ],
                    isCurved: true,
                    color: AppColors.high,
                    barWidth: 2.5,
                    isStrokeCapRound: true,
                    dotData: const FlDotData(show: false),
                  ),
                  // Medium Line
                  LineChartBarData(
                    spots: const [
                      FlSpot(0, 22),
                      FlSpot(1, 24),
                      FlSpot(2, 28),
                      FlSpot(3, 25),
                      FlSpot(4, 30),
                      FlSpot(5, 27),
                    ],
                    isCurved: true,
                    color: AppColors.medium,
                    barWidth: 2,
                    isStrokeCapRound: true,
                    dotData: const FlDotData(show: false),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: AppTypography.caption.copyWith(color: AppColors.textSecondary, fontSize: 10.5),
        ),
      ],
    );
  }
}
