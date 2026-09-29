import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../shared/widgets/enterprise_card.dart';

class TopPrecursorsList extends StatelessWidget {
  const TopPrecursorsList({super.key});

  @override
  Widget build(BuildContext context) {
    final precursors = [
      {
        'rank': '1',
        'category': 'Hazardous Energy (LOTO)',
        'share': '28%',
        'count': '68 reports',
        'trend': '+32%',
        'isSurge': true,
        'riskColor': AppColors.critical,
      },
      {
        'rank': '2',
        'category': 'Working at Height',
        'share': '21%',
        'count': '51 reports',
        'trend': '-4%',
        'isSurge': false,
        'riskColor': AppColors.high,
      },
      {
        'rank': '3',
        'category': 'Confined Space Entry',
        'share': '17%',
        'count': '42 reports',
        'trend': '+12%',
        'isSurge': true,
        'riskColor': AppColors.critical,
      },
      {
        'rank': '4',
        'category': 'Process Safety & Hydrocarbons',
        'share': '14%',
        'count': '34 reports',
        'trend': '+5%',
        'isSurge': false,
        'riskColor': AppColors.high,
      },
      {
        'rank': '5',
        'category': 'Lifting & Rigging Operations',
        'share': '11%',
        'count': '27 reports',
        'trend': '-2%',
        'isSurge': false,
        'riskColor': AppColors.medium,
      },
    ];

    return EnterpriseCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'Top SIF Precursors',
                  style: AppTypography.sectionTitle.copyWith(fontSize: 16),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.surfaceSecondary,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text('Ranked by Severity', style: AppTypography.caption.copyWith(fontSize: 11)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...precursors.map((item) {
            final color = item['riskColor'] as Color;
            final isSurge = item['isSurge'] as bool;
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceSecondary,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Center(
                      child: Text(
                        item['rank'] as String,
                        style: AppTypography.caption.copyWith(fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                item['category'] as String,
                                style: AppTypography.bodySmall.copyWith(fontWeight: FontWeight.w600),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (isSurge) ...[
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                                decoration: BoxDecoration(
                                  color: AppColors.criticalBg,
                                  borderRadius: BorderRadius.circular(3),
                                ),
                                child: Text(
                                  'SURGE',
                                  style: AppTypography.overline.copyWith(
                                    color: AppColors.critical,
                                    fontSize: 8.5,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        Text(
                          '${item['count']} • Trend: ${item['trend']}',
                          style: AppTypography.caption.copyWith(color: AppColors.textSecondary, fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    item['share'] as String,
                    style: AppTypography.bodyLarge.copyWith(
                      fontWeight: FontWeight.w800,
                      color: color,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
