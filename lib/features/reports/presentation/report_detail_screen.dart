import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../shared/models/report_model.dart';
import '../../../shared/widgets/oil_header.dart';
import '../../../shared/widgets/enterprise_card.dart';
import '../../../shared/widgets/sif_risk_badge.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../ai_analysis/presentation/ai_analysis_screen.dart';
import '../../actions/presentation/create_action_dialog.dart';
import '../../auth/providers/auth_provider.dart';
import '../providers/reports_provider.dart';

class ReportDetailScreen extends ConsumerStatefulWidget {
  final String reportId;

  const ReportDetailScreen({super.key, required this.reportId});

  @override
  ConsumerState<ReportDetailScreen> createState() => _ReportDetailScreenState();
}

class _ReportDetailScreenState extends ConsumerState<ReportDetailScreen> {
  final TextEditingController _commentController = TextEditingController();

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  void _submitComment(ReportModel report) {
    final text = _commentController.text.trim();
    if (text.isEmpty) return;

    final user = ref.read(authProvider).user;
    final comment = ReportComment(
      id: 'CMT-${DateTime.now().millisecondsSinceEpoch}',
      authorName: user.name,
      authorRole: user.role,
      message: text,
      createdAt: DateTime.now(),
    );

    ref.read(reportsProvider.notifier).addComment(report.id, comment);
    _commentController.clear();
    FocusScope.of(context).unfocus();
  }

  @override
  Widget build(BuildContext context) {
    final reports = ref.watch(reportsProvider);
    final report = reports.firstWhere((r) => r.id == widget.reportId, orElse: () => reports.first);
    final analysis = report.sifAnalysis;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: OilHeader(
        title: 'Report Details',
        subtitle: report.id,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status & SIF Potential Header
            EnterpriseCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          report.id,
                          style: AppTypography.headingMedium,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      if (analysis != null) SifRiskBadge(potential: analysis.sifPotential),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Report Type: ${report.reportType} • Submitted by ${report.submittedByName} (${report.submittedByRole})',
                    style: AppTypography.caption,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Submitted: ${DateFormat('yyyy-MM-dd HH:mm').format(report.submittedAt)}',
                    style: AppTypography.caption.copyWith(color: AppColors.textTertiary),
                  ),
                  const Divider(height: 24),
                  // Lifecycle Status Selector
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('LIFECYCLE STATUS', style: AppTypography.overline),
                      DropdownButton<ReportStatus>(
                        value: report.status,
                        isDense: true,
                        underline: const SizedBox(),
                        items: ReportStatus.values.map((s) {
                          return DropdownMenuItem<ReportStatus>(
                            value: s,
                            child: Text(s.label, style: AppTypography.bodySmall.copyWith(fontWeight: FontWeight.w600)),
                          );
                        }).toList(),
                        onChanged: (newStatus) {
                          if (newStatus != null) {
                            ref.read(reportsProvider.notifier).updateReportStatus(report.id, newStatus);
                          }
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Observation Text Box
            EnterpriseCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('OBSERVATION DESCRIPTION', style: AppTypography.overline),
                  const SizedBox(height: 8),
                  Text(
                    report.observationText,
                    style: AppTypography.bodyMedium.copyWith(height: 1.55),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // AI Intelligence Quick Card
            if (analysis != null) ...[
              EnterpriseCard(
                padding: const EdgeInsets.all(16),
                backgroundColor: AppColors.surfaceSecondary,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              const Icon(Icons.auto_awesome, size: 18, color: AppColors.info),
                              const SizedBox(width: 8),
                              Flexible(
                                child: Text(
                                  'SIF Sentinel AI Intelligence',
                                  style: AppTypography.sectionTitle.copyWith(fontSize: 15),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${(analysis.confidence * 100).toInt()}% confidence',
                          style: AppTypography.caption.copyWith(color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      analysis.explanation,
                      style: AppTypography.bodySmall.copyWith(color: AppColors.textPrimary),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: CustomButton(
                            label: 'View Detailed AI Analysis',
                            variant: ButtonVariant.primary,
                            icon: Icons.analytics_outlined,
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (ctx) => AISafetyAnalysisScreen(report: report),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Contextual Metadata Grid
            EnterpriseCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('CONTEXTUAL METADATA', style: AppTypography.overline),
                  const SizedBox(height: 12),
                  _buildMetaRow('Operational Site', report.site),
                  _buildMetaRow('Department', report.department),
                  _buildMetaRow('Work Activity', report.workActivity),
                  _buildMetaRow('Equipment / Tag', report.equipment),
                  if (report.latitude != null)
                    _buildMetaRow('GPS Coordinates', '${report.latitude!.toStringAsFixed(4)}, ${report.longitude!.toStringAsFixed(4)}'),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Corrective Actions CTA
            Row(
              children: [
                Expanded(
                  child: CustomButton(
                    label: 'Assign Corrective Action',
                    variant: ButtonVariant.secondary,
                    icon: Icons.add_task_rounded,
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
            const SizedBox(height: 16),

            // Audit Trail
            EnterpriseCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('ENTERPRISE AUDIT TRAIL', style: AppTypography.overline),
                  const SizedBox(height: 12),
                  ...report.auditTrail.map((entry) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            margin: const EdgeInsets.only(top: 5),
                            decoration: const BoxDecoration(
                              color: AppColors.primaryRed,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        entry.action,
                                        style: AppTypography.bodySmall.copyWith(fontWeight: FontWeight.w700),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      DateFormat('MMM dd HH:mm').format(entry.timestamp),
                                      style: AppTypography.caption.copyWith(fontSize: 10.5),
                                    ),
                                  ],
                                ),
                                Text(
                                  'By: ${entry.performedBy} • ${entry.details}',
                                  style: AppTypography.caption.copyWith(color: AppColors.textSecondary),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Comments Section
            EnterpriseCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('SAFETY NOTES & COMMENTS', style: AppTypography.overline),
                      Text('${report.comments.length} notes', style: AppTypography.caption),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ...report.comments.map((c) {
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  '${c.authorName} (${c.authorRole})',
                                  style: AppTypography.caption.copyWith(fontWeight: FontWeight.w700),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(DateFormat('MMM dd HH:mm').format(c.createdAt), style: AppTypography.caption.copyWith(fontSize: 10)),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(c.message, style: AppTypography.bodySmall),
                        ],
                      ),
                    );
                  }),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _commentController,
                          decoration: const InputDecoration(
                            hintText: 'Add an HSE observation note...',
                            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton.filled(
                        style: IconButton.styleFrom(backgroundColor: AppColors.primaryRed),
                        onPressed: () => _submitComment(report),
                        icon: const Icon(Icons.send_rounded, size: 18, color: Colors.white),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildMetaRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
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
            child: Text(value, style: AppTypography.bodySmall.copyWith(fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}
