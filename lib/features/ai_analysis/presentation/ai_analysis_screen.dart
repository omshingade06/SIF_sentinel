import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/security/rbac_service.dart';
import '../../../shared/models/report_model.dart';
import '../../../shared/models/sif_analysis_model.dart';
import '../../../shared/widgets/oil_header.dart';
import '../../../shared/widgets/sif_risk_badge.dart';
import '../../../shared/widgets/enterprise_card.dart';
import '../../../shared/widgets/risk_gauge.dart';
import '../../../shared/widgets/highlighted_phrase_text.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../reports/providers/reports_provider.dart';
import '../../actions/presentation/create_action_dialog.dart';
import '../../auth/providers/auth_provider.dart';
import 'hitl_review_dialog.dart';

class AISafetyAnalysisScreen extends ConsumerWidget {
  final ReportModel report;

  const AISafetyAnalysisScreen({super.key, required this.report});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch live updated report from provider
    final reports = ref.watch(reportsProvider);
    final currentReport = reports.firstWhere((r) => r.id == report.id, orElse: () => report);
    final analysis = currentReport.sifAnalysis;
    final currentUser = ref.watch(authProvider).user;
    final canOverride = currentUser.hasPermission(Permission.overrideAiClassification);

    if (analysis == null) {
      return Scaffold(
        appBar: const OilHeader(title: 'AI Safety Intelligence'),
        body: const Center(child: Text('No AI analysis available for this report.')),
      );
    }

    final int confidencePercent = (analysis.confidence * 100).toInt();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: OilHeader(
        title: 'AI Safety Analysis',
        subtitle: currentReport.id,
        actions: [
          if (canOverride)
            IconButton(
              tooltip: 'Human-in-the-Loop Review (HSE Officer)',
              icon: const Icon(Icons.edit_note_rounded, color: AppColors.primaryRed),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (ctx) => HitlReviewDialog(report: currentReport),
                );
              },
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero SIF Potential & Priority Banner
            _buildHeroRiskBanner(context, currentReport, analysis, confidencePercent),
            const SizedBox(height: 16),

            // Human Validation Status if applicable
            if (analysis.isHumanValidated) ...[
              _buildHumanValidationBanner(analysis),
              const SizedBox(height: 16),
            ],

            // Section 1: Official Structured AI Output (Section 3 Requirement)
            _buildStructuredIntelligenceCard(analysis),
            const SizedBox(height: 16),

            // Section 2: Explainable AI — "Why was this flagged?"
            _buildExplainableReasoningCard(analysis),
            const SizedBox(height: 16),

            // Section 3: In-Text Evidence Highlighting
            _buildEvidenceHighlightingCard(currentReport, analysis),
            const SizedBox(height: 16),

            // Section 4: SIF Risk Factor Breakdown
            _buildSifFactorBreakdownCard(analysis),
            const SizedBox(height: 16),

            // Section 5: Recommended Procedural Actions
            _buildRecommendedActionsCard(context, currentReport, analysis),
            const SizedBox(height: 16),

            // Footer Transparency & Decision Support Notice
            _buildDecisionSupportNotice(analysis),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroRiskBanner(
    BuildContext context,
    ReportModel report,
    SifAnalysisModel analysis,
    int confidencePercent,
  ) {
    Color accentColor;

    switch (analysis.sifPotential) {
      case SifPotential.critical:
        accentColor = AppColors.critical;
        break;
      case SifPotential.high:
        accentColor = AppColors.high;
        break;
      case SifPotential.medium:
        accentColor = const Color(0xFFB45309);
        break;
      case SifPotential.low:
        accentColor = AppColors.low;
        break;
    }

    return EnterpriseCard(
      padding: const EdgeInsets.all(18),
      backgroundColor: Colors.white,
      border: BorderSide(color: accentColor.withValues(alpha: 0.4), width: 1.5),
      indicatorColor: accentColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'SIF PRECURSOR CLASSIFICATION',
                  style: AppTypography.overline.copyWith(
                    color: AppColors.textSecondary,
                    letterSpacing: 0.8,
                    fontSize: 9.5,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.surfaceSecondary,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.auto_awesome, size: 12, color: AppColors.info),
                    const SizedBox(width: 4),
                    Text(
                      'AI Confidence: $confidencePercent%',
                      style: AppTypography.caption.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                        fontSize: 10.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 12,
            runSpacing: 10,
            children: [
              SifRiskBadge(potential: analysis.sifPotential, size: BadgeSize.medium),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: analysis.isSifPotential ? AppColors.criticalBg : AppColors.lowBg,
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: analysis.isSifPotential ? AppColors.critical.withValues(alpha: 0.3) : AppColors.low.withValues(alpha: 0.3)),
                        ),
                        child: Text(
                          analysis.classification,
                          style: AppTypography.caption.copyWith(
                            color: analysis.isSifPotential ? AppColors.critical : AppColors.low,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.primaryBlack,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'IOGP: ${analysis.lifeSavingRule}',
                          style: AppTypography.caption.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 10.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Report: ${report.id} • ${report.site}',
                    style: AppTypography.caption.copyWith(color: AppColors.textSecondary),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHumanValidationBanner(SifAnalysisModel analysis) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.purpleBg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.purple.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.verified_user_rounded, color: AppColors.purple, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Validated by Safety Officer: ${analysis.validatedBy ?? "HSE Authority"}',
                  style: AppTypography.bodySmall.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.purple,
                  ),
                ),
                if (analysis.validationNotes != null && analysis.validationNotes!.isNotEmpty)
                  Text(
                    analysis.validationNotes!,
                    style: AppTypography.caption.copyWith(color: AppColors.textPrimary),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStructuredIntelligenceCard(SifAnalysisModel analysis) {
    return EnterpriseCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.hub_outlined, color: AppColors.primaryRed, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Structured SIF Precursor Intelligence',
                  style: AppTypography.sectionTitle.copyWith(fontSize: 15),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildStructuredRow('SIF Potential', analysis.sifPotential.label, isHighlight: true),
          _buildStructuredRow('Classification', analysis.classification),
          _buildStructuredRow('Confidence', '${(analysis.confidence * 100).toInt()}%'),
          _buildStructuredRow('IOGP Life-Saving Rule', analysis.lifeSavingRule),
          _buildStructuredRow('Detected Activity', analysis.detectedActivity),
          _buildStructuredRow('Detected Hazard', analysis.detectedHazards.isNotEmpty ? analysis.detectedHazards.join(', ') : 'General Safety'),
          _buildStructuredRow('Unsafe Act', analysis.detectedUnsafeActs.isNotEmpty ? analysis.detectedUnsafeActs.first : 'Procedural non-compliance'),
          _buildStructuredRow('Barrier Failure', analysis.detectedBarrierFailure),
          _buildStructuredRow('Potential Exposure', analysis.potentialExposure),
          _buildStructuredRow('Potential Consequence', analysis.potentialConsequences.isNotEmpty ? analysis.potentialConsequences.first : 'Minor localized injury'),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.surfaceSecondary,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('RECOMMENDED REVIEW', style: AppTypography.overline.copyWith(fontSize: 9.5, color: AppColors.primaryRed)),
                const SizedBox(height: 2),
                Text(analysis.recommendedReview, style: AppTypography.bodySmall.copyWith(fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStructuredRow(String label, String val, {bool isHighlight = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(label, style: AppTypography.caption.copyWith(color: AppColors.textSecondary)),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 3,
            child: Text(
              val,
              style: AppTypography.bodySmall.copyWith(
                fontWeight: isHighlight ? FontWeight.w800 : FontWeight.w600,
                color: isHighlight ? AppColors.critical : AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExplainableReasoningCard(SifAnalysisModel analysis) {
    return EnterpriseCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.primaryRed.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Icon(Icons.psychology_outlined, color: AppColors.primaryRed, size: 18),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Why was this observation flagged?',
                  style: AppTypography.sectionTitle.copyWith(fontSize: 15),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.border),
            ),
            child: Text(
              analysis.explanation,
              style: AppTypography.bodyMedium.copyWith(
                height: 1.55,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEvidenceHighlightingCard(ReportModel report, SifAnalysisModel analysis) {
    return EnterpriseCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    const Icon(Icons.find_in_page_outlined, size: 18, color: AppColors.info),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        'Extracted Text Evidence',
                        style: AppTypography.sectionTitle.copyWith(fontSize: 15),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              Text(
                '${analysis.evidenceSpans.length} triggers',
                style: AppTypography.caption.copyWith(color: AppColors.textTertiary, fontSize: 11),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Legend
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: [
              _buildEvidenceLegend(AppColors.criticalBg, AppColors.critical, 'Barrier / Control Failure'),
              _buildEvidenceLegend(AppColors.highBg, const Color(0xFFC2410C), 'High Energy Hazard'),
              _buildEvidenceLegend(AppColors.purpleBg, AppColors.purple, 'Worker Exposure'),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.surfaceSecondary,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.border),
            ),
            child: HighlightedPhraseText(
              text: report.observationText,
              evidenceSpans: analysis.evidenceSpans,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEvidenceLegend(Color bg, Color fg, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(2),
            border: Border.all(color: fg.withValues(alpha: 0.5)),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: AppTypography.caption.copyWith(fontSize: 11, color: AppColors.textSecondary),
        ),
      ],
    );
  }

  Widget _buildSifFactorBreakdownCard(SifAnalysisModel analysis) {
    return EnterpriseCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    const Icon(Icons.bar_chart_rounded, size: 18, color: AppColors.textPrimary),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        'SIF Factor Breakdown',
                        style: AppTypography.sectionTitle.copyWith(fontSize: 15),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              Text(
                'AI-Derived Factors',
                style: AppTypography.caption.copyWith(
                  color: AppColors.textTertiary,
                  fontStyle: FontStyle.italic,
                  fontSize: 11,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...analysis.riskFactors.map((factor) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: RiskFactorBar(
                label: factor.name,
                score: factor.score,
                description: factor.description,
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildRecommendedActionsCard(
    BuildContext context,
    ReportModel report,
    SifAnalysisModel analysis,
  ) {
    return EnterpriseCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    const Icon(Icons.checklist_rtl_rounded, size: 18, color: AppColors.primaryRed),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        'AI Recommended Actions',
                        style: AppTypography.sectionTitle.copyWith(fontSize: 15),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.surfaceSecondary,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text('Guidance', style: AppTypography.caption.copyWith(fontSize: 10.5)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...analysis.recommendedActions.asMap().entries.map((entry) {
            final idx = entry.key + 1;
            final actionText = entry.value;
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                      color: AppColors.primaryRed.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '$idx',
                        style: AppTypography.caption.copyWith(
                          fontWeight: FontWeight.w700,
                          color: AppColors.primaryRed,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      actionText,
                      style: AppTypography.bodyMedium.copyWith(fontSize: 13.5),
                    ),
                  ),
                ],
              ),
            );
          }),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: CustomButton(
                  label: 'Create Corrective Action',
                  variant: ButtonVariant.primary,
                  icon: Icons.add_task_rounded,
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (ctx) => CreateActionDialog(
                        relatedReport: report,
                        defaultTitle: analysis.recommendedActions.isNotEmpty
                            ? analysis.recommendedActions.first
                            : 'Mitigate ${analysis.detectedHazards.first}',
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDecisionSupportNotice(SifAnalysisModel analysis) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceSecondary,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.info_outline_rounded, size: 14, color: AppColors.textSecondary),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  'Decision Support Notice & Model Transparency',
                  style: AppTypography.caption.copyWith(fontWeight: FontWeight.w700),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Model Version: ${analysis.modelVersion} • Analyzed: ${analysis.analyzedAt.toLocal().toString().substring(0, 16)}\n'
            'SIF Sentinel provides AI-assisted identification and prioritization of observations with SIF potential for decision support. AI output is decision support and does not replace official OIL safety classification or statutory HSE authority.',
            style: AppTypography.caption.copyWith(
              color: AppColors.textSecondary,
              fontSize: 11,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

