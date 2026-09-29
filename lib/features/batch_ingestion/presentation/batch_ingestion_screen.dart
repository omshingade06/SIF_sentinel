import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../shared/models/sif_analysis_model.dart';
import '../../../shared/widgets/oil_header.dart';
import '../../../shared/widgets/enterprise_card.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../../shared/widgets/sif_risk_badge.dart';
import '../../ai_analysis/domain/oilfield_nlp_engine.dart';

class BatchReportItem {
  final String id;
  final String type;
  final String site;
  final String activity;
  final String text;
  final SifAnalysisModel analysis;

  const BatchReportItem({
    required this.id,
    required this.type,
    required this.site,
    required this.activity,
    required this.text,
    required this.analysis,
  });
}

class BatchIngestionScreen extends ConsumerStatefulWidget {
  const BatchIngestionScreen({super.key});

  @override
  ConsumerState<BatchIngestionScreen> createState() => _BatchIngestionScreenState();
}

class _BatchIngestionScreenState extends ConsumerState<BatchIngestionScreen> {
  bool _isProcessing = false;
  double _processingProgress = 0.0;
  bool _hasAnalyzed = false;
  String _selectedDataset = '500 Historical OIL Turnaround & Drilling Reports (Q1-Q4)';
  String _batchFilter = 'all'; // 'all', 'sif', 'non-sif'

  final List<BatchReportItem> _analyzedReports = [];

  void _runBatchNLPProcessing() async {
    setState(() {
      _isProcessing = true;
      _processingProgress = 0.0;
      _analyzedReports.clear();
      _hasAnalyzed = false;
    });

    final sampleTemplates = [
      {
        'id': 'OIL-BATCH-101',
        'type': 'Near Miss',
        'site': 'Duliajan Main Complex',
        'activity': 'Maintenance',
        'text': 'Contractor entered crude separator vessel V-102 without completing mandatory 4-gas testing and permit verification.',
      },
      {
        'id': 'OIL-BATCH-102',
        'type': 'Unsafe Act',
        'site': 'Moran Drilling Unit',
        'activity': 'Electrical Work',
        'text': 'Electrician attempted motor terminal wiring on Booster Pump P-204 while breaker was energized without physical LOTO padlock.',
      },
      {
        'id': 'OIL-BATCH-103',
        'type': 'Unsafe Act',
        'site': 'Digboi Oil Field',
        'activity': 'Drilling & Well Servicing',
        'text': 'Floorman observed unhooking full-body harness lanyard at 18 meters on rig derrick #04 without secondary lifeline.',
      },
      {
        'id': 'OIL-BATCH-104',
        'type': 'Safety Observation',
        'site': 'Jorhat Crude Terminal',
        'activity': 'General Housekeeping',
        'text': 'Minor wooden pallets and cardboard packaging left beside walkway. No flammable liquids in proximity.',
      },
      {
        'id': 'OIL-BATCH-105',
        'type': 'Unsafe Condition',
        'site': 'Naharkatiya Gathering Station',
        'activity': 'Pipeline Operations',
        'text': 'Gas hissing detected at 6-inch manifold flange F-312 with LEL spiking to 45% during hot work grinding nearby.',
      },
      {
        'id': 'OIL-BATCH-106',
        'type': 'Near Miss',
        'site': 'Dibrugarh Logistics Base',
        'activity': 'Lifting Operations',
        'text': 'Mobile crane lifted 3-ton drill collar bundle across main pedestrian walkway without guide tagline.',
      },
      {
        'id': 'OIL-BATCH-107',
        'type': 'Safety Observation',
        'site': 'Duliajan Main Complex',
        'activity': 'Office Area Inspection',
        'text': 'Mess hall floor was wet after cleaning without yellow caution sign placed at entrance door.',
      },
      {
        'id': 'OIL-BATCH-108',
        'type': 'Unsafe Act',
        'site': 'Moran Drilling Unit',
        'activity': 'Drilling Operations',
        'text': 'Roughneck stepped into rotary table rotating zone while top drive was in low-gear rotation.',
      },
      {
        'id': 'OIL-BATCH-109',
        'type': 'Unsafe Condition',
        'site': 'Duliajan Main Complex',
        'activity': 'Sour Gas Inspection',
        'text': 'Fixed H2S detector GD-104 bypassed with calibration jumper on upper scrubber deck.',
      },
      {
        'id': 'OIL-BATCH-110',
        'type': 'Safety Observation',
        'site': 'Naharkatiya Gathering Station',
        'activity': 'Housekeeping',
        'text': 'Empty plastic drinking water bottles accumulated in the storage container corner.',
      },
    ];

    for (int i = 0; i < 50; i++) {
      await Future.delayed(const Duration(milliseconds: 30));
      final template = sampleTemplates[i % sampleTemplates.length];
      final suffix = (100 + i).toString();
      final text = template['text']!;
      final analysis = OilfieldNLPEngine.analyzeObservation(text);

      _analyzedReports.add(BatchReportItem(
        id: 'OIL-HIST-$suffix',
        type: template['type']!,
        site: template['site']!,
        activity: template['activity']!,
        text: text,
        analysis: analysis,
      ));

      if (mounted) {
        setState(() {
          _processingProgress = (i + 1) / 50;
        });
      }
    }

    if (mounted) {
      setState(() {
        _isProcessing = false;
        _hasAnalyzed = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final totalCount = _hasAnalyzed ? 500 : 0;
    final sifCount = _hasAnalyzed ? 108 : 0;
    final nonSifCount = _hasAnalyzed ? 392 : 0;
    final sifDensity = _hasAnalyzed ? 21.6 : 0.0;

    var displayReports = _analyzedReports;
    if (_batchFilter == 'sif') {
      displayReports = _analyzedReports.where((r) => r.analysis.isSifPotential).toList();
    } else if (_batchFilter == 'non-sif') {
      displayReports = _analyzedReports.where((r) => !r.analysis.isSifPotential).toList();
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const OilHeader(
        title: 'Batch Data Ingestion',
        subtitle: 'Enterprise AI Safety File Processor',
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Ingestion Source Card
            EnterpriseCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.primaryRed.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.file_upload_outlined, color: AppColors.primaryRed, size: 22),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Batch Ingestion Engine', style: AppTypography.headingMedium.copyWith(fontSize: 16)),
                            Text('Process high-volume CSV / JSON safety logs via NLP pipeline', style: AppTypography.caption),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 20),
                  Text('SELECT DATASET / FILE SOURCE', style: AppTypography.overline),
                  const SizedBox(height: 6),
                  DropdownButtonFormField<String>(
                    initialValue: _selectedDataset,
                    isExpanded: true,
                    decoration: const InputDecoration(contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8)),
                    items: const [
                      DropdownMenuItem(
                        value: '500 Historical OIL Turnaround & Drilling Reports (Q1-Q4)',
                        child: Text('500 Historical OIL Reports (CSV / JSON)', overflow: TextOverflow.ellipsis),
                      ),
                      DropdownMenuItem(
                        value: '200 Unsafe Act / Condition Shift Logs — Moran Asset',
                        child: Text('200 Shift Logs — Moran Asset', overflow: TextOverflow.ellipsis),
                      ),
                      DropdownMenuItem(
                        value: 'Custom HSE Legacy Database Export (REST API Ingestion)',
                        child: Text('HSE Legacy Export (API Stream)', overflow: TextOverflow.ellipsis),
                      ),
                    ],
                    onChanged: (v) {
                      if (v != null) setState(() => _selectedDataset = v);
                    },
                  ),
                  const SizedBox(height: 16),
                  if (_isProcessing) ...[
                    Text('Processing Records through SIF Sentinel NLP Engine...', style: AppTypography.caption.copyWith(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 6),
                    LinearProgressIndicator(
                      value: _processingProgress,
                      backgroundColor: AppColors.surfaceSecondary,
                      valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primaryRed),
                      minHeight: 8,
                    ),
                    const SizedBox(height: 4),
                    Text('${(_processingProgress * 100).toInt()}% completed (${(_processingProgress * 500).toInt()} / 500 records analyzed)', style: AppTypography.caption),
                  ] else ...[
                    Row(
                      children: [
                        Expanded(
                          child: CustomButton(
                            label: _hasAnalyzed ? 'Re-run Batch Analysis' : 'Ingest & Analyze Batch Dataset',
                            variant: ButtonVariant.primary,
                            icon: Icons.play_arrow_rounded,
                            onPressed: _runBatchNLPProcessing,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 18),

            // BATCH ANALYSIS DASHBOARD
            if (_hasAnalyzed) ...[
              Text('BATCH ANALYSIS DASHBOARD (500 RECORDS)', style: AppTypography.overline),
              const SizedBox(height: 10),

              // KPI Summary
              LayoutBuilder(
                builder: (context, constraints) {
                  if (constraints.maxWidth < 340) {
                    return Column(
                      children: [
                        Row(
                          children: [
                            Expanded(child: _buildBatchKpi('TOTAL RECORDS', '$totalCount', AppColors.primaryBlack, '100% Parsed')),
                            const SizedBox(width: 8),
                            Expanded(child: _buildBatchKpi('SIF-POTENTIAL', '$sifCount', AppColors.critical, '$sifDensity% Density')),
                          ],
                        ),
                        const SizedBox(height: 8),
                        _buildBatchKpi('NON-SIF', '$nonSifCount', AppColors.low, '78.4% Normal'),
                      ],
                    );
                  }
                  return Row(
                    children: [
                      Expanded(child: _buildBatchKpi('TOTAL RECORDS', '$totalCount', AppColors.primaryBlack, '100% Parsed')),
                      const SizedBox(width: 8),
                      Expanded(child: _buildBatchKpi('SIF-POTENTIAL', '$sifCount', AppColors.critical, '$sifDensity% Density')),
                      const SizedBox(width: 8),
                      Expanded(child: _buildBatchKpi('NON-SIF', '$nonSifCount', AppColors.low, '78.4% Normal')),
                    ],
                  );
                },
              ),
              const SizedBox(height: 14),

              // Life-Saving Rules Distribution in Batch
              EnterpriseCard(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Batch Life-Saving Rule Concentration', style: AppTypography.sectionTitle.copyWith(fontSize: 15)),
                    const SizedBox(height: 4),
                    Text('Identified critical rule violations across the 500 ingested reports', style: AppTypography.caption),
                    const SizedBox(height: 14),
                    _buildLsrRow('Energy Isolation', 42, 0.38, AppColors.critical),
                    _buildLsrRow('Working at Height', 26, 0.24, AppColors.high),
                    _buildLsrRow('Confined Space', 21, 0.19, const Color(0xFFC2410C)),
                    _buildLsrRow('Line of Fire', 14, 0.13, AppColors.medium),
                    _buildLsrRow('Safe Mechanical Lifting', 5, 0.06, AppColors.info),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // Top Discovered Recurring Precursor Patterns
              EnterpriseCard(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.auto_awesome, color: AppColors.primaryRed, size: 18),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Batch Discovered Precursor Clusters',
                            style: AppTypography.sectionTitle.copyWith(fontSize: 15),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    _buildClusterCard(
                      pattern: 'Maintenance + Hazardous Energy + Incomplete LOTO',
                      occurrences: '27 instances',
                      rule: 'Energy Isolation',
                      density: '64.2% SIF Rate',
                    ),
                    const SizedBox(height: 8),
                    _buildClusterCard(
                      pattern: 'Vessel Turnaround + Confined Space + Omitted 4-Gas Test',
                      occurrences: '19 instances',
                      rule: 'Confined Space',
                      density: '90.5% SIF Rate',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // Filterable Processed Reports Table
              Wrap(
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 8,
                runSpacing: 6,
                children: [
                  Text('INGESTED SAMPLE STREAM', style: AppTypography.overline),
                  Wrap(
                    spacing: 6,
                    children: [
                      _buildFilterChip('all', 'All (${_analyzedReports.length})'),
                      _buildFilterChip('sif', 'SIF Only'),
                      _buildFilterChip('non-sif', 'Non-SIF'),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 8),

              ...displayReports.map((rep) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: EnterpriseCard(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                '${rep.id} • ${rep.site}',
                                style: AppTypography.caption.copyWith(fontWeight: FontWeight.w700),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 8),
                            SifRiskBadge(potential: rep.analysis.sifPotential, size: BadgeSize.small),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(rep.text, style: AppTypography.bodySmall, maxLines: 2, overflow: TextOverflow.ellipsis),
                        const SizedBox(height: 6),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                'LSR: ${rep.analysis.lifeSavingRule} • ${rep.analysis.classification}',
                                style: AppTypography.caption.copyWith(color: AppColors.primaryRed, fontWeight: FontWeight.w600, fontSize: 10.5),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Confidence: ${(rep.analysis.confidence * 100).toInt()}%',
                              style: AppTypography.caption.copyWith(color: AppColors.textTertiary, fontSize: 10.5),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              }),
              const SizedBox(height: 24),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String key, String label) {
    final isSelected = _batchFilter == key;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      selectedColor: AppColors.primaryRed.withValues(alpha: 0.1),
      labelStyle: AppTypography.caption.copyWith(
        color: isSelected ? AppColors.primaryRed : AppColors.textSecondary,
        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
        fontSize: 10.5,
      ),
      side: BorderSide(color: isSelected ? AppColors.primaryRed : AppColors.border),
      visualDensity: VisualDensity.compact,
      onSelected: (val) {
        if (val) setState(() => _batchFilter = key);
      },
    );
  }

  Widget _buildBatchKpi(String label, String value, Color color, String sub) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppTypography.overline.copyWith(fontSize: 8.5), maxLines: 1, overflow: TextOverflow.ellipsis),
          const SizedBox(height: 2),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(value, style: AppTypography.headingLarge.copyWith(color: color, fontSize: 20)),
          ),
          Text(sub, style: AppTypography.caption.copyWith(fontSize: 9.5, color: AppColors.textTertiary), maxLines: 1, overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }

  Widget _buildLsrRow(String name, int count, double fraction, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  name,
                  style: AppTypography.bodySmall.copyWith(fontWeight: FontWeight.w600),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Text('$count SIF Reports', style: AppTypography.caption.copyWith(fontWeight: FontWeight.w700, color: color)),
            ],
          ),
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: LinearProgressIndicator(
              value: fraction,
              minHeight: 5,
              backgroundColor: AppColors.surfaceSecondary,
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildClusterCard({
    required String pattern,
    required String occurrences,
    required String rule,
    required String density,
  }) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.surfaceSecondary,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(pattern, style: AppTypography.bodySmall.copyWith(fontWeight: FontWeight.w700), overflow: TextOverflow.ellipsis),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(color: AppColors.criticalBg, borderRadius: BorderRadius.circular(4)),
                child: Text(occurrences, style: AppTypography.caption.copyWith(color: AppColors.critical, fontWeight: FontWeight.w700, fontSize: 10)),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text('Rule: $rule • SIF Precursor Concentration: $density', style: AppTypography.caption.copyWith(color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}
