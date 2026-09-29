import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';

class SafetyScoreGauge extends StatelessWidget {
  final double score; // 0 to 100
  final double trendDelta; // e.g. +6.4%
  final String statusText;

  const SafetyScoreGauge({
    super.key,
    required this.score,
    this.trendDelta = 6.4,
    this.statusText = 'Stable compared with previous period',
  });

  @override
  Widget build(BuildContext context) {
    Color ringColor = AppColors.low;
    if (score < 60) {
      ringColor = AppColors.critical;
    } else if (score < 75) {
      ringColor = AppColors.medium;
    }

    return Column(
      children: [
        SizedBox(
          width: 140,
          height: 140,
          child: Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 130,
                height: 130,
                child: CircularProgressIndicator(
                  value: score / 100,
                  strokeWidth: 10,
                  backgroundColor: AppColors.surfaceSecondary,
                  valueColor: AlwaysStoppedAnimation<Color>(ringColor),
                  strokeCap: StrokeCap.round,
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        score.toInt().toString(),
                        style: AppTypography.displayMedium.copyWith(
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        ' / 100',
                        style: AppTypography.caption.copyWith(
                          color: AppColors.textTertiary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.lowBg,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.arrow_upward_rounded, size: 11, color: AppColors.low),
                        const SizedBox(width: 2),
                        Text(
                          '+${trendDelta.toStringAsFixed(1)}%',
                          style: AppTypography.overline.copyWith(
                            color: AppColors.low,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Text(
          statusText,
          style: AppTypography.bodySmall.copyWith(
            color: AppColors.textSecondary,
            fontSize: 12,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4),
        Text(
          '* Application-derived risk indicator; not official statutory safety KPI.',
          style: AppTypography.caption.copyWith(
            color: AppColors.textTertiary,
            fontSize: 10,
            fontStyle: FontStyle.italic,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class RiskFactorBar extends StatelessWidget {
  final String label;
  final double score; // 0.0 to 1.0
  final String description;
  final Color? barColor;

  const RiskFactorBar({
    super.key,
    required this.label,
    required this.score,
    required this.description,
    this.barColor,
  });

  @override
  Widget build(BuildContext context) {
    Color effectiveColor = barColor ?? AppColors.high;
    if (score >= 0.85) {
      effectiveColor = AppColors.critical;
    } else if (score >= 0.70) {
      effectiveColor = AppColors.high;
    } else if (score >= 0.45) {
      effectiveColor = AppColors.medium;
    } else {
      effectiveColor = AppColors.low;
    }

    final int percentage = (score * 100).toInt();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                label,
                style: AppTypography.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '$percentage%',
              style: AppTypography.bodyMedium.copyWith(
                fontWeight: FontWeight.w700,
                color: effectiveColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: score,
            minHeight: 8,
            backgroundColor: AppColors.surfaceSecondary,
            valueColor: AlwaysStoppedAnimation<Color>(effectiveColor),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          description,
          style: AppTypography.caption.copyWith(
            color: AppColors.textSecondary,
            fontSize: 11.5,
          ),
        ),
      ],
    );
  }
}
