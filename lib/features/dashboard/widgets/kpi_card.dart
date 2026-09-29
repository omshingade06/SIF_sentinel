import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../shared/widgets/enterprise_card.dart';

class KpiCard extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final Color accentColor;
  final VoidCallback? onTap;

  const KpiCard({
    super.key,
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.accentColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return EnterpriseCard(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  title.toUpperCase(),
                  style: AppTypography.overline.copyWith(
                    fontSize: 9.5,
                    letterSpacing: 0.6,
                    color: AppColors.textSecondary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 4),
              Container(
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(icon, size: 14, color: accentColor),
              ),
            ],
          ),
          const SizedBox(height: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              style: AppTypography.displayMedium.copyWith(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
                height: 1.1,
              ),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: AppTypography.caption.copyWith(
              fontSize: 10.5,
              color: AppColors.textSecondary,
              height: 1.1,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
