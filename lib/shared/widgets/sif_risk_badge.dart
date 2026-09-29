import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../models/sif_analysis_model.dart';

enum BadgeSize { small, medium, large }

class SifRiskBadge extends StatelessWidget {
  final SifPotential potential;
  final BadgeSize size;
  final bool showIcon;

  const SifRiskBadge({
    super.key,
    required this.potential,
    this.size = BadgeSize.medium,
    this.showIcon = true,
  });

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color fg;
    Color border;
    IconData icon;
    String label;

    switch (potential) {
      case SifPotential.critical:
        bg = AppColors.criticalBg;
        fg = AppColors.critical;
        border = AppColors.critical.withValues(alpha: 0.3);
        icon = Icons.warning_rounded;
        label = size == BadgeSize.small ? 'CRITICAL SIF' : 'CRITICAL SIF PRECURSOR';
        break;
      case SifPotential.high:
        bg = AppColors.highBg;
        fg = AppColors.high;
        border = AppColors.high.withValues(alpha: 0.3);
        icon = Icons.error_outline_rounded;
        label = size == BadgeSize.small ? 'HIGH SIF' : 'HIGH SIF POTENTIAL';
        break;
      case SifPotential.medium:
        bg = AppColors.mediumBg;
        fg = const Color(0xFFB45309);
        border = AppColors.medium.withValues(alpha: 0.4);
        icon = Icons.info_outline_rounded;
        label = 'MEDIUM RISK';
        break;
      case SifPotential.low:
        bg = AppColors.lowBg;
        fg = AppColors.low;
        border = AppColors.low.withValues(alpha: 0.3);
        icon = Icons.check_circle_outline_rounded;
        label = size == BadgeSize.small ? 'LOW RISK' : 'LOW SIF POTENTIAL';
        break;
    }

    final double fontSize = size == BadgeSize.small ? 10.5 : (size == BadgeSize.large ? 13 : 11.5);
    final double iconSize = size == BadgeSize.small ? 12 : (size == BadgeSize.large ? 16 : 14);
    final EdgeInsets padding = size == BadgeSize.small
        ? const EdgeInsets.symmetric(horizontal: 6, vertical: 3)
        : (size == BadgeSize.large
            ? const EdgeInsets.symmetric(horizontal: 12, vertical: 6)
            : const EdgeInsets.symmetric(horizontal: 9, vertical: 4));

    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: border, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (showIcon) ...[
            Icon(icon, size: iconSize, color: fg),
            const SizedBox(width: 5),
          ],
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.overline.copyWith(
                color: fg,
                fontSize: fontSize,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
