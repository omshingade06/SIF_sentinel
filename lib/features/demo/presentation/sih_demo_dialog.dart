import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/constants/demo_scenarios.dart';
import '../../../shared/models/report_model.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../ai_analysis/domain/oilfield_nlp_engine.dart';
import '../../ai_analysis/presentation/ai_analysis_screen.dart';
import '../../reports/providers/reports_provider.dart';

class SihDemoDialog extends ConsumerStatefulWidget {
  const SihDemoDialog({super.key});

  @override
  ConsumerState<SihDemoDialog> createState() => _SihDemoDialogState();
}

class _SihDemoDialogState extends ConsumerState<SihDemoDialog> {
  int _selectedScenarioIndex = 0;
  bool _isAnalyzing = false;

  void _runSelectedScenario(DemoScenario scenario) async {
    setState(() => _isAnalyzing = true);

    await Future.delayed(const Duration(milliseconds: 600));

    final sifAnalysis = OilfieldNLPEngine.analyzeObservation(scenario.observationText);
    final reportId = 'OIL-SIM-${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}';

    final newReport = ReportModel(
      id: reportId,
      reportType: scenario.reportType,
      observationText: scenario.observationText,
      site: scenario.site,
      department: scenario.department,
      workActivity: scenario.title,
      equipment: 'OIL Field Equipment',
      submittedByName: 'Safety Engineer / AI Test Suite',
      submittedByRole: 'Safety Officer',
      submittedAt: DateTime.now(),
      status: ReportStatus.aiAnalyzed,
      sifAnalysis: sifAnalysis,
      auditTrail: [
        ReportAuditEntry(
          action: 'AI Safety Model Operational Scenario Run',
          performedBy: 'HSE Simulator Engine',
          details: 'Scenario test analyzed with SIF Sentinel NLP Engine.',
          timestamp: DateTime.now(),
        ),
      ],
    );

    ref.read(reportsProvider.notifier).addReport(newReport);

    if (mounted) {
      setState(() => _isAnalyzing = false);
      Navigator.of(context).pop();
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (ctx) => AISafetyAnalysisScreen(report: newReport),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final scenarios = DemoScenarios.judgeScenarios;
    final active = scenarios[_selectedScenarioIndex];

    return Dialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Container(
        constraints: BoxConstraints(
          maxWidth: 580,
          maxHeight: MediaQuery.of(context).size.height * 0.88,
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primaryRed.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.science_outlined, color: AppColors.primaryRed, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              'AI Scenario Simulator',
                              style: AppTypography.headingMedium.copyWith(fontSize: 17),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.primaryBlack,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              'TEST LAB',
                              style: AppTypography.overline.copyWith(color: Colors.white, fontSize: 9.0),
                            ),
                          ),
                        ],
                      ),
                      Text(
                        'Simulate & verify AI precursor detection on critical oilfield scenarios',
                        style: AppTypography.caption.copyWith(color: AppColors.textSecondary, fontSize: 11),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close_rounded, size: 20),
                ),
              ],
            ),
            const Divider(height: 24),
            // Scenario Selection Chips
            Text('SELECT TEST SCENARIO', style: AppTypography.overline),
            const SizedBox(height: 8),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: List.generate(scenarios.length, (idx) {
                  final s = scenarios[idx];
                  final isSelected = idx == _selectedScenarioIndex;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(s.title),
                      selected: isSelected,
                      selectedColor: AppColors.primaryRed.withValues(alpha: 0.12),
                      side: BorderSide(
                        color: isSelected ? AppColors.primaryRed : AppColors.border,
                      ),
                      labelStyle: AppTypography.bodySmall.copyWith(
                        color: isSelected ? AppColors.primaryRed : AppColors.textPrimary,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                      ),
                      onSelected: (val) {
                        if (val) setState(() => _selectedScenarioIndex = idx);
                      },
                    ),
                  );
                }),
              ),
            ),
            const SizedBox(height: 16),
            // Active Scenario Details Box
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                ),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              active.title,
                              style: AppTypography.sectionTitle.copyWith(fontSize: 15),
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
                              active.expectedSifPotential,
                              style: AppTypography.overline.copyWith(
                                color: AppColors.critical,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      // Responsive Site & Department tags
                      Wrap(
                        spacing: 12,
                        runSpacing: 4,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.location_on_outlined, size: 14, color: AppColors.textSecondary),
                              const SizedBox(width: 4),
                              Flexible(
                                child: Text(
                                  active.site,
                                  style: AppTypography.caption,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.business_outlined, size: 14, color: AppColors.textSecondary),
                              const SizedBox(width: 4),
                              Flexible(
                                child: Text(
                                  active.department,
                                  style: AppTypography.caption,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const Divider(height: 18),
                      Text('UNSTRUCTURED OBSERVATION TEXT (INPUT)', style: AppTypography.overline.copyWith(fontSize: 9.5)),
                      const SizedBox(height: 6),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Text(
                          '"${active.observationText}"',
                          style: AppTypography.bodyMedium.copyWith(
                            fontStyle: FontStyle.italic,
                            color: AppColors.textPrimary,
                            fontSize: 13,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text('AI PREDICTION HIGHLIGHT', style: AppTypography.overline.copyWith(fontSize: 9.5)),
                      const SizedBox(height: 6),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.shield_outlined, size: 14, color: AppColors.primaryRed),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              'Hazard Category: ${active.expectedHazard}',
                              style: AppTypography.bodySmall.copyWith(fontWeight: FontWeight.w600),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.lightbulb_outline, size: 14, color: AppColors.info),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              active.keyReason,
                              style: AppTypography.caption.copyWith(color: AppColors.textSecondary),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 14),
            // Actions
            Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  child: CustomButton(
                    label: 'Run AI SIF Analysis',
                    variant: ButtonVariant.primary,
                    icon: Icons.auto_awesome,
                    isLoading: _isAnalyzing,
                    onPressed: () => _runSelectedScenario(active),
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: CustomButton(
                    label: 'Reload Baseline Data',
                    variant: ButtonVariant.outlined,
                    icon: Icons.refresh_rounded,
                    onPressed: () {
                      ref.read(reportsProvider.notifier).resetToDemoData();
                      ref.read(actionsProvider.notifier).resetToDemoData();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Operational baseline dataset reloaded successfully.'),
                          backgroundColor: AppColors.primaryBlack,
                        ),
                      );
                      Navigator.of(context).pop();
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
