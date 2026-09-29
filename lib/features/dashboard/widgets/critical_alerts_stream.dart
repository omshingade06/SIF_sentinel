import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../shared/models/sif_analysis_model.dart';
import '../../../shared/widgets/enterprise_card.dart';
import '../../../shared/widgets/sif_risk_badge.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../ai_analysis/presentation/ai_analysis_screen.dart';
import '../../actions/presentation/create_action_dialog.dart';
import '../../reports/providers/reports_provider.dart';

class CriticalAlertsStream extends ConsumerWidget {
  const CriticalAlertsStream({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reports = ref.watch(reportsProvider);
    final criticalReports = reports
        .where((r) => r.sifAnalysis?.sifPotential == SifPotential.critical || r.sifAnalysis?.sifPotential == SifPotential.high)
        .take(3)
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: AppColors.critical,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      'Requires Immediate Attention',
                      style: AppTypography.sectionTitle.copyWith(fontSize: 15.5),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
              decoration: BoxDecoration(
                color: AppColors.criticalBg,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                '7 ACTIVE ALERTS',
                style: AppTypography.overline.copyWith(
                  color: AppColors.critical,
                  fontSize: 9.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...criticalReports.map((report) {
          final analysis = report.sifAnalysis!;
          final primaryHazard = analysis.detectedHazards.isNotEmpty ? analysis.detectedHazards.first : 'Critical Hazard';

          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: EnterpriseCard(
              indicatorColor: AppColors.critical,
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: SifRiskBadge(potential: analysis.sifPotential, size: BadgeSize.small),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        report.id,
                        style: AppTypography.caption.copyWith(
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    report.observationText,
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 12,
                    runSpacing: 4,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.location_on_outlined, size: 14, color: AppColors.textSecondary),
                          const SizedBox(width: 4),
                          Text(
                            report.site.split(' ').first,
                            style: AppTypography.caption,
                          ),
                        ],
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.shield_outlined, size: 14, color: AppColors.primaryRed),
                          const SizedBox(width: 4),
                          Text(
                            primaryHazard,
                            style: AppTypography.caption.copyWith(
                              color: AppColors.primaryRed,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const Divider(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: CustomButton(
                          label: 'Review AI',
                          variant: ButtonVariant.outlined,
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (ctx) => AISafetyAnalysisScreen(report: report),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: CustomButton(
                          label: 'Assign Action',
                          variant: ButtonVariant.primary,
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (ctx) => CreateActionDialog(relatedReport: report),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }
}
