import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../shared/widgets/oil_header.dart';
import '../../../shared/widgets/enterprise_card.dart';
import '../../../shared/widgets/risk_gauge.dart';
import '../../../shared/widgets/demo_banner.dart';
import '../../auth/providers/auth_provider.dart';
import '../../reports/providers/reports_provider.dart';
import '../../demo/presentation/sih_demo_dialog.dart';
import '../../actions/presentation/action_center_screen.dart';
import '../../reports/presentation/reports_list_screen.dart';
import '../../life_saving_rules/presentation/life_saving_rules_screen.dart';
import '../../analytics/presentation/site_safety_map_screen.dart';
import '../widgets/kpi_card.dart';
import '../widgets/sif_classification_card.dart';
import '../widgets/site_sif_density_widget.dart';
import '../widgets/sif_trend_chart.dart';
import '../widgets/top_precursors_list.dart';
import '../widgets/critical_alerts_stream.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final user = authState.user;
    final reports = ref.watch(reportsProvider);
    final actions = ref.watch(actionsProvider);

    final openActionsCount = actions.where((a) => a.status.name != 'completed').length;
    final totalReportsCount = 1264 + reports.length;
    final sifReportsCount = 226 + reports.where((r) => r.sifAnalysis?.isSifPotential ?? false).length;
    final sifDensityPercent = ((sifReportsCount / totalReportsCount) * 100).toStringAsFixed(1);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: OilHeader(
        title: 'SIF Sentinel',
        subtitle: 'OIL Safety Intelligence Command Center',
      ),
      body: Column(
        children: [
          // Demo Banner with quick judge trigger
          DemoBanner(
            onLaunchDemoMode: () {
              showDialog(
                context: context,
                builder: (ctx) => const SihDemoDialog(),
              );
            },
          ),
          Expanded(
            child: RefreshIndicator(
              color: AppColors.primaryRed,
              onRefresh: () async {
                await Future.delayed(const Duration(milliseconds: 400));
              },
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(left: 14, right: 14, top: 12, bottom: 28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Greeting & Sub-header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Good morning, ${user.role}',
                                style: AppTypography.headingLarge.copyWith(fontSize: 20),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Safety Intelligence Overview • ${user.assignedSite}',
                                style: AppTypography.bodySmall.copyWith(fontSize: 11.5),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 7,
                                height: 7,
                                decoration: const BoxDecoration(
                                  color: AppColors.low,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 5),
                              Text(
                                'ONLINE',
                                style: AppTypography.overline.copyWith(
                                  fontSize: 9.5,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Top 6 Official SIF Sentinel KPI Cards (Section 8)
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final isCompact = constraints.maxWidth < 340;
                        if (isCompact) {
                          return Column(
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: KpiCard(
                                      title: 'Total Reports',
                                      value: '$totalReportsCount',
                                      subtitle: 'Unstructured HSE logs',
                                      icon: Icons.assignment_outlined,
                                      accentColor: AppColors.primaryBlack,
                                      onTap: () {
                                        ref.read(selectedRiskFilterProvider.notifier).state = null;
                                        Navigator.of(context).push(
                                          MaterialPageRoute(builder: (ctx) => const ReportsListScreen()),
                                        );
                                      },
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: KpiCard(
                                      title: 'SIF Potential',
                                      value: '$sifReportsCount',
                                      subtitle: 'High fatal risk cases',
                                      icon: Icons.warning_amber_rounded,
                                      accentColor: AppColors.critical,
                                      onTap: () {
                                        ref.read(selectedRiskFilterProvider.notifier).state = null;
                                        Navigator.of(context).push(
                                          MaterialPageRoute(builder: (ctx) => const ReportsListScreen()),
                                        );
                                      },
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Expanded(
                                    child: KpiCard(
                                      title: 'SIF Density',
                                      value: '$sifDensityPercent%',
                                      subtitle: 'SIF / Total relevant',
                                      icon: Icons.analytics_outlined,
                                      accentColor: AppColors.primaryRed,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: KpiCard(
                                      title: 'Critical Reports',
                                      value: '27',
                                      subtitle: 'Immediate danger',
                                      icon: Icons.error_outline_rounded,
                                      accentColor: AppColors.critical,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Expanded(
                                    child: KpiCard(
                                      title: 'Open Actions',
                                      value: '$openActionsCount',
                                      subtitle: 'Active supervisor tasks',
                                      icon: Icons.assignment_turned_in_outlined,
                                      accentColor: AppColors.medium,
                                      onTap: () {
                                        Navigator.of(context).push(
                                          MaterialPageRoute(builder: (ctx) => const ActionCenterScreen()),
                                        );
                                      },
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: KpiCard(
                                      title: 'LSR Alerts',
                                      value: '18',
                                      subtitle: 'Life-saving rule alerts',
                                      icon: Icons.shield_outlined,
                                      accentColor: AppColors.high,
                                      onTap: () {
                                        Navigator.of(context).push(
                                          MaterialPageRoute(builder: (ctx) => const LifeSavingRulesScreen()),
                                        );
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          );
                        }
                        return Column(
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: KpiCard(
                                    title: 'Total Reports',
                                    value: '$totalReportsCount',
                                    subtitle: 'Unstructured HSE logs',
                                    icon: Icons.assignment_outlined,
                                    accentColor: AppColors.primaryBlack,
                                    onTap: () {
                                      ref.read(selectedRiskFilterProvider.notifier).state = null;
                                      Navigator.of(context).push(
                                        MaterialPageRoute(builder: (ctx) => const ReportsListScreen()),
                                      );
                                    },
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: KpiCard(
                                    title: 'SIF Potential',
                                    value: '$sifReportsCount',
                                    subtitle: 'High fatal risk cases',
                                    icon: Icons.warning_amber_rounded,
                                    accentColor: AppColors.critical,
                                    onTap: () {
                                      ref.read(selectedRiskFilterProvider.notifier).state = null;
                                      Navigator.of(context).push(
                                        MaterialPageRoute(builder: (ctx) => const ReportsListScreen()),
                                      );
                                    },
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: KpiCard(
                                    title: 'SIF Density',
                                    value: '$sifDensityPercent%',
                                    subtitle: 'SIF / Total relevant',
                                    icon: Icons.analytics_outlined,
                                    accentColor: AppColors.primaryRed,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Expanded(
                                  child: KpiCard(
                                    title: 'Critical Reports',
                                    value: '27',
                                    subtitle: 'Immediate danger',
                                    icon: Icons.error_outline_rounded,
                                    accentColor: AppColors.critical,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: KpiCard(
                                    title: 'Open Actions',
                                    value: '$openActionsCount',
                                    subtitle: 'Active supervisor tasks',
                                    icon: Icons.assignment_turned_in_outlined,
                                    accentColor: AppColors.medium,
                                    onTap: () {
                                      Navigator.of(context).push(
                                        MaterialPageRoute(builder: (ctx) => const ActionCenterScreen()),
                                      );
                                    },
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: KpiCard(
                                    title: 'LSR Alerts',
                                    value: '18',
                                    subtitle: 'Life-saving rule alerts',
                                    icon: Icons.shield_outlined,
                                    accentColor: AppColors.high,
                                    onTap: () {
                                      Navigator.of(context).push(
                                        MaterialPageRoute(builder: (ctx) => const LifeSavingRulesScreen()),
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 14),

                    // Quick Feature Launchers: IOGP Life-Saving Rules & Batch Ingestion
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final isCompact = constraints.maxWidth < 360;
                        final lsrCard = EnterpriseCard(
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(builder: (ctx) => const LifeSavingRulesScreen()),
                            );
                          },
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          backgroundColor: AppColors.primaryBlack,
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: AppColors.primaryRed,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: const Icon(Icons.shield_rounded, color: Colors.white, size: 16),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'IOGP Life-Saving Rules',
                                      style: AppTypography.bodySmall.copyWith(color: Colors.white, fontWeight: FontWeight.w700),
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                    ),
                                    Text('9 Rules Tracked', style: AppTypography.caption.copyWith(color: const Color(0xFFD1D5DB), fontSize: 10)),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 4),
                              const Icon(Icons.chevron_right, color: Colors.white70, size: 16),
                            ],
                          ),
                        );

                        final mapCard = EnterpriseCard(
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(builder: (ctx) => const SiteSafetyMapScreen()),
                            );
                          },
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          backgroundColor: AppColors.surface,
                          border: BorderSide(color: AppColors.primaryRed.withValues(alpha: 0.3)),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: AppColors.primaryRed.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: const Icon(Icons.map_outlined, color: AppColors.primaryRed, size: 16),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Geospatial Safety Map',
                                      style: AppTypography.bodySmall.copyWith(fontWeight: FontWeight.w700),
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                    ),
                                    Text('Upper Assam Basin Heatmap', style: AppTypography.caption.copyWith(color: AppColors.textSecondary, fontSize: 10)),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 4),
                              const Icon(Icons.chevron_right, color: AppColors.textSecondary, size: 16),
                            ],
                          ),
                        );

                        if (isCompact) {
                          return Column(
                            children: [
                              lsrCard,
                              const SizedBox(height: 8),
                              mapCard,
                            ],
                          );
                        }

                        return Row(
                          children: [
                            Expanded(child: lsrCard),
                            const SizedBox(width: 10),
                            Expanded(child: mapCard),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 16),

                    // SIF Classification Dashboard Widget (Section 9)
                    SifClassificationCard(
                      totalReports: totalReportsCount,
                      sifPotentialReports: sifReportsCount,
                      nonSifReports: totalReportsCount - sifReportsCount,
                      sifPercentage: double.parse(sifDensityPercent),
                    ),
                    const SizedBox(height: 16),

                    // SIF Precursor Density by Site (Section 10)
                    const SiteSifDensityWidget(),
                    const SizedBox(height: 16),

                    // Safety Intelligence Score Card
                    EnterpriseCard(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  'Safety Intelligence Index',
                                  style: AppTypography.sectionTitle.copyWith(fontSize: 15),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                                decoration: BoxDecoration(
                                  color: AppColors.lowBg,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  'GOOD STANDING',
                                  style: AppTypography.overline.copyWith(
                                    color: AppColors.low,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 9.5,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          const Center(
                            child: SafetyScoreGauge(score: 82),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),

                    // SIF Trend Chart
                    const SifTrendChart(),
                    const SizedBox(height: 18),

                    // Top SIF Precursors Ranked List
                    const TopPrecursorsList(),
                    const SizedBox(height: 18),

                    // Critical Alerts Feed
                    const CriticalAlertsStream(),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

