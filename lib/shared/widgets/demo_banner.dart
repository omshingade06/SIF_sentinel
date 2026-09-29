import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/constants/oil_constants.dart';

class DemoBanner extends StatelessWidget {
  final VoidCallback? onLaunchDemoMode;

  const DemoBanner({super.key, this.onLaunchDemoMode});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
      decoration: BoxDecoration(
        color: AppColors.primaryBlack,
        border: Border(
          bottom: BorderSide(color: AppColors.primaryRed.withValues(alpha: 0.8), width: 2),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: AppColors.primaryRed,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              'LIVE HSE FEED',
              style: AppTypography.overline.copyWith(
                color: Colors.white,
                fontSize: 8.5,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.5,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              OilConstants.operationalStatus,
              style: AppTypography.caption.copyWith(
                color: const Color(0xFFD1D5DB),
                fontSize: 11,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (onLaunchDemoMode != null) ...[
            const SizedBox(width: 8),
            InkWell(
              onTap: onLaunchDemoMode,
              borderRadius: BorderRadius.circular(4),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.darkCard,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: const Color(0xFF4B5563)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.science_outlined, size: 13, color: AppColors.primaryRed),
                    const SizedBox(width: 4),
                    Text(
                      'AI Simulator',
                      style: AppTypography.caption.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
