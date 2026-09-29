import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/constants/oil_constants.dart';
import '../../../shared/models/report_model.dart';
import '../../../shared/models/sif_analysis_model.dart';
import '../../../shared/widgets/oil_header.dart';
import '../../../shared/widgets/enterprise_card.dart';
import '../../../shared/widgets/sif_risk_badge.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../ai_analysis/presentation/ai_analysis_screen.dart';
import '../providers/reports_provider.dart';
import 'create_report_screen.dart';
import 'report_detail_screen.dart';

class ReportsListScreen extends ConsumerStatefulWidget {
  const ReportsListScreen({super.key});

  @override
  ConsumerState<ReportsListScreen> createState() => _ReportsListScreenState();
}

class _ReportsListScreenState extends ConsumerState<ReportsListScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filteredReports = ref.watch(filteredReportsProvider);
    final selectedType = ref.watch(selectedReportTypeFilterProvider);
    final selectedRisk = ref.watch(selectedRiskFilterProvider);
    final selectedSite = ref.watch(selectedSiteFilterProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: OilHeader(
        title: 'Safety Reports',
        subtitle: '${filteredReports.length} records found',
        actions: [
          IconButton(
            tooltip: 'Filter Options',
            icon: const Icon(Icons.filter_list_rounded),
            onPressed: () => _showFilterBottomSheet(context),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primaryRed,
        foregroundColor: Colors.white,
        elevation: 2,
        icon: const Icon(Icons.add_rounded),
        label: const Text('New Report', style: TextStyle(fontWeight: FontWeight.w700)),
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (ctx) => const CreateReportScreen()),
          );
        },
      ),
      body: Column(
        children: [
          // Search & Active Filter Chips Bar
          _buildSearchBar(),
          _buildActiveFiltersBar(selectedType, selectedRisk, selectedSite),
          const Divider(height: 1),

          // Reports List or Empty State
          Expanded(
            child: filteredReports.isEmpty
                ? EmptyStateWidget(
                    title: 'No Matching Reports Found',
                    message: 'Try adjusting your search keywords or clearing active filters.',
                    actionLabel: 'Clear All Filters',
                    onAction: () {
                      _searchController.clear();
                      ref.read(reportSearchQueryProvider.notifier).state = '';
                      ref.read(selectedReportTypeFilterProvider.notifier).state = null;
                      ref.read(selectedRiskFilterProvider.notifier).state = null;
                      ref.read(selectedSiteFilterProvider.notifier).state = null;
                      ref.read(selectedHazardFilterProvider.notifier).state = null;
                      ref.read(selectedStatusFilterProvider.notifier).state = null;
                    },
                  )
                : ListView.builder(
                    padding: const EdgeInsets.only(left: 16, right: 16, top: 12, bottom: 80),
                    itemCount: filteredReports.length,
                    itemBuilder: (context, index) {
                      final report = filteredReports[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _buildReportCard(context, report),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      color: AppColors.surface,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Search by ID, keyword, hazard, equipment, site...',
          prefixIcon: const Icon(Icons.search_rounded, size: 20, color: AppColors.textSecondary),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear_rounded, size: 18),
                  onPressed: () {
                    _searchController.clear();
                    ref.read(reportSearchQueryProvider.notifier).state = '';
                  },
                )
              : null,
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        ),
        onChanged: (val) {
          ref.read(reportSearchQueryProvider.notifier).state = val;
        },
      ),
    );
  }

  Widget _buildActiveFiltersBar(String? type, SifPotential? risk, String? site) {
    if (type == null && risk == null && site == null) {
      return const SizedBox();
    }

    return Container(
      color: AppColors.surface,
      padding: const EdgeInsets.only(left: 16, right: 16, bottom: 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            Text('ACTIVE:', style: AppTypography.overline.copyWith(fontSize: 10)),
            const SizedBox(width: 8),
            if (risk != null)
              Padding(
                padding: const EdgeInsets.only(right: 6),
                child: Chip(
                  label: Text('Risk: ${risk.label}'),
                  deleteIcon: const Icon(Icons.close, size: 14),
                  onDeleted: () => ref.read(selectedRiskFilterProvider.notifier).state = null,
                ),
              ),
            if (type != null)
              Padding(
                padding: const EdgeInsets.only(right: 6),
                child: Chip(
                  label: Text('Type: $type'),
                  deleteIcon: const Icon(Icons.close, size: 14),
                  onDeleted: () => ref.read(selectedReportTypeFilterProvider.notifier).state = null,
                ),
              ),
            if (site != null)
              Padding(
                padding: const EdgeInsets.only(right: 6),
                child: Chip(
                  label: Text('Site: $site'),
                  deleteIcon: const Icon(Icons.close, size: 14),
                  onDeleted: () => ref.read(selectedSiteFilterProvider.notifier).state = null,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildReportCard(BuildContext context, ReportModel report) {
    final analysis = report.sifAnalysis;
    final primaryHazard = analysis?.detectedHazards.isNotEmpty == true ? analysis!.detectedHazards.first : 'Unclassified';
    final potential = analysis?.sifPotential ?? SifPotential.low;

    Color sideIndicator = AppColors.low;
    if (potential == SifPotential.critical) sideIndicator = AppColors.critical;
    if (potential == SifPotential.high) sideIndicator = AppColors.high;
    if (potential == SifPotential.medium) sideIndicator = AppColors.medium;

    return EnterpriseCard(
      indicatorColor: sideIndicator,
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (ctx) => ReportDetailScreen(reportId: report.id),
          ),
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(
                      report.id,
                      style: AppTypography.bodySmall.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceSecondary,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        report.reportType,
                        style: AppTypography.overline.copyWith(fontSize: 9),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              SifRiskBadge(potential: potential, size: BadgeSize.small),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            report.observationText,
            style: AppTypography.bodyMedium.copyWith(fontSize: 13.5),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 6,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.primaryRed.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  primaryHazard,
                  style: AppTypography.caption.copyWith(
                    color: AppColors.primaryRed,
                    fontWeight: FontWeight.w600,
                    fontSize: 11,
                  ),
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.location_on_outlined, size: 13, color: AppColors.textTertiary),
                  const SizedBox(width: 2),
                  Text(
                    report.site.split(' ').first,
                    style: AppTypography.caption.copyWith(fontSize: 11),
                  ),
                ],
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.access_time_rounded, size: 13, color: AppColors.textTertiary),
                  const SizedBox(width: 2),
                  Text(
                    DateFormat('MMM dd').format(report.submittedAt),
                    style: AppTypography.caption.copyWith(fontSize: 11),
                  ),
                ],
              ),
            ],
          ),
          const Divider(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceSecondary,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    'STATUS: ${report.status.label.toUpperCase()}',
                    style: AppTypography.overline.copyWith(
                      color: AppColors.textSecondary,
                      fontSize: 9.0,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              InkWell(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (ctx) => AISafetyAnalysisScreen(report: report),
                    ),
                  );
                },
                borderRadius: BorderRadius.circular(4),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.auto_awesome, size: 13, color: AppColors.info),
                      const SizedBox(width: 4),
                      Text(
                        'AI Analysis',
                        style: AppTypography.caption.copyWith(
                          color: AppColors.info,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showFilterBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return Consumer(
          builder: (context, ref, _) {
            final activeType = ref.watch(selectedReportTypeFilterProvider);
            final activeRisk = ref.watch(selectedRiskFilterProvider);
            final activeSite = ref.watch(selectedSiteFilterProvider);

            return ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.85,
              ),
              child: SafeArea(
                top: false,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Container(
                          width: 36,
                          height: 4,
                          margin: const EdgeInsets.only(bottom: 14),
                          decoration: BoxDecoration(
                            color: AppColors.border,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              'Filter Safety Records',
                              style: AppTypography.headingMedium.copyWith(fontSize: 18),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              ref.read(selectedReportTypeFilterProvider.notifier).state = null;
                              ref.read(selectedRiskFilterProvider.notifier).state = null;
                              ref.read(selectedSiteFilterProvider.notifier).state = null;
                              Navigator.of(ctx).pop();
                            },
                            child: const Text('Reset'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text('SIF POTENTIAL LEVEL', style: AppTypography.overline),
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 8,
                        runSpacing: 6,
                        children: SifPotential.values.map((r) {
                          final isSelected = activeRisk == r;
                          return ChoiceChip(
                            label: Text(r.label),
                            selected: isSelected,
                            onSelected: (val) {
                              ref.read(selectedRiskFilterProvider.notifier).state = val ? r : null;
                            },
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 14),
                      Text('REPORT TYPE', style: AppTypography.overline),
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 8,
                        runSpacing: 6,
                        children: OilConstants.reportTypes.map((t) {
                          final isSelected = activeType == t;
                          return ChoiceChip(
                            label: Text(t),
                            selected: isSelected,
                            onSelected: (val) {
                              ref.read(selectedReportTypeFilterProvider.notifier).state = val ? t : null;
                            },
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 14),
                      Text('OPERATIONAL SITE', style: AppTypography.overline),
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: OilConstants.sites.map((s) {
                          final name = s['name'] as String;
                          final isSelected = activeSite == name;
                          return ChoiceChip(
                            label: Text(name.split(' ').first),
                            selected: isSelected,
                            onSelected: (val) {
                              ref.read(selectedSiteFilterProvider.notifier).state = val ? name : null;
                            },
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
