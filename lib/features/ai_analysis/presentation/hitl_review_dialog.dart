import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/constants/oil_constants.dart';
import '../../../shared/models/report_model.dart';
import '../../../shared/models/sif_analysis_model.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../reports/providers/reports_provider.dart';
import '../../auth/providers/auth_provider.dart';

class HitlReviewDialog extends ConsumerStatefulWidget {
  final ReportModel report;

  const HitlReviewDialog({super.key, required this.report});

  @override
  ConsumerState<HitlReviewDialog> createState() => _HitlReviewDialogState();
}

class _HitlReviewDialogState extends ConsumerState<HitlReviewDialog> {
  late SifPotential _selectedPotential;
  late String _selectedClassification;
  late String _selectedLifeSavingRule;
  late List<String> _selectedHazards;
  final TextEditingController _notesController = TextEditingController();

  final List<String> _iogpRules = [
    'Energy Isolation',
    'Confined Space',
    'Line of Fire',
    'Working at Height',
    'Hot Work',
    'Work Authorisation',
    'Safe Mechanical Lifting',
    'Bypassing Safety Controls',
    'Driving',
    'None / Non-LSR',
  ];

  @override
  void initState() {
    super.initState();
    final analysis = widget.report.sifAnalysis;
    _selectedPotential = analysis?.sifPotential ?? SifPotential.high;
    _selectedClassification = analysis?.classification ?? 'SIF-Potential';
    _selectedLifeSavingRule = analysis?.lifeSavingRule ?? 'Confined Space';
    _selectedHazards = List<String>.from(analysis?.detectedHazards ?? []);
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authProvider).user;

    return Dialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 540, maxHeight: 720),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.purpleBg,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.rate_review_rounded, color: AppColors.purple, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Human-in-the-Loop Validation', style: AppTypography.headingMedium.copyWith(fontSize: 17)),
                      Text('Official HSE Officer assessment and calibration override', style: AppTypography.caption),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close_rounded, size: 20),
                ),
              ],
            ),
            const Divider(height: 20),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // SIF Classification Override
                    Text('OFFICIAL SIF CLASSIFICATION', style: AppTypography.overline),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: ['SIF-Potential', 'Non-SIF-Potential'].map((c) {
                        final isSel = _selectedClassification == c;
                        return ChoiceChip(
                          label: Text(c),
                          selected: isSel,
                          selectedColor: c == 'SIF-Potential' ? AppColors.criticalBg : AppColors.lowBg,
                          side: BorderSide(
                            color: isSel ? (c == 'SIF-Potential' ? AppColors.critical : AppColors.low) : AppColors.border,
                          ),
                          labelStyle: AppTypography.bodySmall.copyWith(
                            fontWeight: FontWeight.w700,
                            color: isSel ? (c == 'SIF-Potential' ? AppColors.critical : AppColors.low) : AppColors.textPrimary,
                          ),
                          onSelected: (val) {
                            if (val) {
                              setState(() {
                                _selectedClassification = c;
                                if (c == 'Non-SIF-Potential') {
                                  _selectedPotential = SifPotential.low;
                                } else if (_selectedPotential == SifPotential.low) {
                                  _selectedPotential = SifPotential.high;
                                }
                              });
                            }
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),

                    // Risk Level
                    Text('ADJUST SIF POTENTIAL LEVEL', style: AppTypography.overline),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: SifPotential.values.map((pot) {
                        final isSelected = pot == _selectedPotential;
                        Color chipColor = AppColors.surfaceSecondary;
                        Color textCol = AppColors.textPrimary;
                        if (isSelected) {
                          if (pot == SifPotential.critical) {
                            chipColor = AppColors.criticalBg;
                            textCol = AppColors.critical;
                          } else if (pot == SifPotential.high) {
                            chipColor = AppColors.highBg;
                            textCol = AppColors.high;
                          } else if (pot == SifPotential.medium) {
                            chipColor = AppColors.mediumBg;
                            textCol = const Color(0xFFB45309);
                          } else {
                            chipColor = AppColors.lowBg;
                            textCol = AppColors.low;
                          }
                        }
                        return ChoiceChip(
                          label: Text(pot.label),
                          selected: isSelected,
                          selectedColor: chipColor,
                          side: BorderSide(color: isSelected ? textCol : AppColors.border),
                          labelStyle: AppTypography.bodySmall.copyWith(
                            color: textCol,
                            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                          ),
                          onSelected: (val) {
                            if (val) {
                              setState(() {
                                _selectedPotential = pot;
                                if (pot == SifPotential.low) {
                                  _selectedClassification = 'Non-SIF-Potential';
                                } else {
                                  _selectedClassification = 'SIF-Potential';
                                }
                              });
                            }
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),

                    // IOGP Life-Saving Rule Override
                    Text('MAP IOGP LIFE-SAVING RULE', style: AppTypography.overline),
                    const SizedBox(height: 6),
                    DropdownButtonFormField<String>(
                      initialValue: _iogpRules.contains(_selectedLifeSavingRule) ? _selectedLifeSavingRule : _iogpRules.first,
                      isExpanded: true,
                      decoration: const InputDecoration(contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8)),
                      items: _iogpRules.map((rule) {
                        return DropdownMenuItem<String>(
                          value: rule,
                          child: Text(rule, style: AppTypography.bodyMedium),
                        );
                      }).toList(),
                      onChanged: (v) {
                        if (v != null) setState(() => _selectedLifeSavingRule = v);
                      },
                    ),
                    const SizedBox(height: 16),

                    // Modify Hazard Taxonomy
                    Text('VALIDATE / MODIFY HAZARD TAXONOMY', style: AppTypography.overline),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: OilConstants.hazardTaxonomy.map((h) {
                        final name = h['name']!;
                        final isSelected = _selectedHazards.contains(name);
                        return FilterChip(
                          label: Text(name),
                          selected: isSelected,
                          selectedColor: AppColors.primaryRed.withValues(alpha: 0.1),
                          checkmarkColor: AppColors.primaryRed,
                          labelStyle: AppTypography.caption.copyWith(
                            color: isSelected ? AppColors.primaryRed : AppColors.textPrimary,
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                          ),
                          side: BorderSide(color: isSelected ? AppColors.primaryRed : AppColors.border),
                          onSelected: (val) {
                            setState(() {
                              if (val) {
                                _selectedHazards.add(name);
                              } else {
                                _selectedHazards.remove(name);
                              }
                            });
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),

                    // Validation Notes
                    Text('SAFETY OFFICER RATIONALE & FEEDBACK', style: AppTypography.overline),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _notesController,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        hintText: 'Enter specific technical/operational rationale for adjusting AI assessment...',
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: CustomButton(
                    label: 'Cancel',
                    variant: ButtonVariant.outlined,
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: CustomButton(
                    label: 'Save & Log Feedback',
                    variant: ButtonVariant.primary,
                    onPressed: () {
                      final currentAnalysis = widget.report.sifAnalysis!;
                      final updatedAnalysis = currentAnalysis.copyWith(
                        classification: _selectedClassification,
                        sifPotential: _selectedPotential,
                        lifeSavingRule: _selectedLifeSavingRule,
                        detectedHazards: _selectedHazards,
                      );
                      ref.read(reportsProvider.notifier).updateSifAnalysis(
                            widget.report.id,
                            updatedAnalysis,
                            user.name,
                            _notesController.text.trim().isNotEmpty
                                ? _notesController.text.trim()
                                : 'Validated by ${user.role}.',
                          );
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Human validation logged in audit trail and training feedback store.'),
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

