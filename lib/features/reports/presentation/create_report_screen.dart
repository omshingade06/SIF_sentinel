import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/constants/oil_constants.dart';
import '../../../shared/models/report_model.dart';
import '../../../shared/widgets/oil_header.dart';
import '../../../shared/widgets/enterprise_card.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../../shared/widgets/voice_input_modal.dart';
import '../../ai_analysis/domain/oilfield_nlp_engine.dart';
import '../../ai_analysis/presentation/ai_analysis_screen.dart';
import '../../auth/providers/auth_provider.dart';
import '../providers/reports_provider.dart';

class CreateReportScreen extends ConsumerStatefulWidget {
  const CreateReportScreen({super.key});

  @override
  ConsumerState<CreateReportScreen> createState() => _CreateReportScreenState();
}

class _CreateReportScreenState extends ConsumerState<CreateReportScreen> {
  int _currentStep = 0;
  String _selectedReportType = 'Near Miss';
  final TextEditingController _observationController = TextEditingController();
  final TextEditingController _workActivityController = TextEditingController(text: 'Routine Maintenance Activity');
  final TextEditingController _equipmentController = TextEditingController(text: 'Separator Vessel V-102');
  String _selectedSite = 'Duliajan Main Complex';
  String _selectedDepartment = 'Mechanical Maintenance';
  bool _isGpsEnabled = true;
  bool _isAnalyzing = false;
  final List<String> _attachedPhotos = [];

  @override
  void dispose() {
    _observationController.dispose();
    _workActivityController.dispose();
    _equipmentController.dispose();
    super.dispose();
  }

  void _analyzeAndSubmit() async {
    final text = _observationController.text.trim();
    if (text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter or speak an observation description.'),
          backgroundColor: AppColors.critical,
        ),
      );
      return;
    }

    setState(() => _isAnalyzing = true);

    // Run AI NLP Pipeline
    await Future.delayed(const Duration(milliseconds: 700));
    final sifAnalysis = OilfieldNLPEngine.analyzeObservation(text);

    final currentUser = ref.read(authProvider).user;
    final reportId = 'OIL-2026-00${(429 + (DateTime.now().millisecond % 500))}';

    final newReport = ReportModel(
      id: reportId,
      reportType: _selectedReportType,
      observationText: text,
      site: _selectedSite,
      department: _selectedDepartment,
      workActivity: _workActivityController.text.trim().isNotEmpty
          ? _workActivityController.text.trim()
          : 'General Field Activity',
      equipment: _equipmentController.text.trim().isNotEmpty
          ? _equipmentController.text.trim()
          : 'Field Asset',
      submittedByName: currentUser.name,
      submittedByRole: currentUser.role,
      submittedAt: DateTime.now(),
      status: ReportStatus.aiAnalyzed,
      sifAnalysis: sifAnalysis,
      photoUrls: _attachedPhotos,
      latitude: _isGpsEnabled ? 27.3592 : null,
      longitude: _isGpsEnabled ? 95.3188 : null,
      auditTrail: [
        ReportAuditEntry(
          action: 'Report Submitted',
          performedBy: currentUser.name,
          details: 'Submitted via mobile safety reporting module.',
          timestamp: DateTime.now(),
        ),
        ReportAuditEntry(
          action: 'AI Analysis Completed',
          performedBy: 'SIF-Sentinel-NLP-Engine',
          details: 'Detected SIF Potential: ${sifAnalysis.sifPotential.label} (${(sifAnalysis.confidence * 100).toInt()}% confidence).',
          timestamp: DateTime.now(),
        ),
      ],
    );

    ref.read(reportsProvider.notifier).addReport(newReport);

    if (mounted) {
      setState(() => _isAnalyzing = false);
      // Navigate to Hero AI Analysis Screen
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (ctx) => AISafetyAnalysisScreen(report: newReport),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const OilHeader(
        title: 'New Safety Report',
        subtitle: 'Mobile Observation Submission',
      ),
      body: Column(
        children: [
          // Step Progress Bar
          _buildStepHeader(),
          // Active Step View
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: _buildCurrentStepContent(),
            ),
          ),
          // Bottom Navigation Buttons
          _buildBottomBar(),
        ],
      ),
    );
  }

  Widget _buildStepHeader() {
    final steps = ['Type', 'Observation', 'Context', 'AI Review'];
    return Container(
      color: AppColors.surface,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isVeryCompact = constraints.maxWidth < 340;
          return Row(
            children: List.generate(steps.length, (idx) {
              final isPassed = idx < _currentStep;
              final isCurrent = idx == _currentStep;
              return Expanded(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        color: isCurrent
                            ? AppColors.primaryRed
                            : (isPassed ? AppColors.primaryBlack : AppColors.surfaceSecondary),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isCurrent || isPassed ? Colors.transparent : AppColors.border,
                        ),
                      ),
                      child: Center(
                        child: isPassed
                            ? const Icon(Icons.check, size: 11, color: Colors.white)
                            : Text(
                                '${idx + 1}',
                                style: AppTypography.caption.copyWith(
                                  color: isCurrent ? Colors.white : AppColors.textSecondary,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 9.5,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(width: 3),
                    if (!isVeryCompact || isCurrent)
                      Flexible(
                        child: Text(
                          steps[idx],
                          style: AppTypography.caption.copyWith(
                            color: isCurrent ? AppColors.textPrimary : AppColors.textTertiary,
                            fontWeight: isCurrent ? FontWeight.w700 : FontWeight.w500,
                            fontSize: 9.5,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    if (idx < steps.length - 1)
                      Container(
                        width: 4,
                        height: 1,
                        color: isPassed ? AppColors.primaryBlack : AppColors.border,
                        margin: const EdgeInsets.symmetric(horizontal: 2),
                      ),
                  ],
                ),
              );
            }),
          );
        },
      ),
    );
  }

  Widget _buildCurrentStepContent() {
    switch (_currentStep) {
      case 0:
        return _buildStep1Type();
      case 1:
        return _buildStep2Observation();
      case 2:
        return _buildStep3Context();
      case 3:
        return _buildStep4Review();
      default:
        return const SizedBox();
    }
  }

  // STEP 1: Select Report Type
  Widget _buildStep1Type() {
    final types = [
      {
        'title': 'Near Miss',
        'desc': 'An unplanned event that did not result in injury, illness, or damage—but had the potential to do so.',
        'icon': Icons.warning_amber_rounded,
        'badge': 'High SIF Value',
      },
      {
        'title': 'Unsafe Act',
        'desc': 'Behavior or performance of work in a manner that violates safety rules, bypasses controls, or increases risk.',
        'icon': Icons.person_off_outlined,
        'badge': 'Behavioral Factor',
      },
      {
        'title': 'Unsafe Condition',
        'desc': 'A physical, mechanical, or environmental worksite condition that could cause accident or equipment damage.',
        'icon': Icons.handyman_outlined,
        'badge': 'Physical Hazard',
      },
      {
        'title': 'Safety Observation',
        'desc': 'General worksite safety walk observation, positive practice, or proactive hazard notification.',
        'icon': Icons.visibility_outlined,
        'badge': 'General HSE',
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Step 1: Select Observation Classification', style: AppTypography.sectionTitle),
        const SizedBox(height: 4),
        Text('Choose the type of safety event you are reporting', style: AppTypography.bodySmall),
        const SizedBox(height: 16),
        ...types.map((t) {
          final isSelected = _selectedReportType == t['title'];
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: EnterpriseCard(
              onTap: () => setState(() => _selectedReportType = t['title'] as String),
              border: BorderSide(
                color: isSelected ? AppColors.primaryRed : AppColors.border,
                width: isSelected ? 1.8 : 1.0,
              ),
              backgroundColor: isSelected ? AppColors.primaryRed.withValues(alpha: 0.04) : AppColors.surface,
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.primaryRed : AppColors.surfaceSecondary,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      t['icon'] as IconData,
                      color: isSelected ? Colors.white : AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                t['title'] as String,
                                style: AppTypography.bodyLarge.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: isSelected ? AppColors.primaryRed : AppColors.textPrimary,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.surfaceSecondary,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                t['badge'] as String,
                                style: AppTypography.overline.copyWith(fontSize: 9.5),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          t['desc'] as String,
                          style: AppTypography.caption.copyWith(color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                  if (isSelected)
                    const Icon(Icons.check_circle_rounded, color: AppColors.primaryRed, size: 22),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  // STEP 2: Describe Observation
  Widget _buildStep2Observation() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Step 2: Describe Observation',
                    style: AppTypography.sectionTitle.copyWith(fontSize: 16),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    'Free-form unstructured safety event description',
                    style: AppTypography.caption,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            // Voice Input Button
            ElevatedButton.icon(
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (ctx) => VoiceInputModal(
                    onTextTranscribed: (text) {
                      setState(() {
                        _observationController.text = text;
                      });
                    },
                  ),
                );
              },
              icon: const Icon(Icons.mic_rounded, size: 15),
              label: const Text('Voice', style: TextStyle(fontSize: 12)),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBlack,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                visualDensity: VisualDensity.compact,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _observationController,
          maxLines: 6,
          decoration: const InputDecoration(
            hintText: 'Describe what happened in detail...\n\nExample: "During maintenance activity at Separator Vessel V-102, worker entered the confined space without completing gas testing. Entry permit was not properly verified by the shift engineer."',
          ),
        ),
        const SizedBox(height: 16),
        // Quick Sample Snippets
        Text('QUICK TEST SAMPLES (TAP TO INSERT)', style: AppTypography.overline),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _buildSampleChip('Confined Space + No Gas Test', 'During turnaround maintenance at Separator Vessel V-102, worker entered confined space without gas testing and permit was not verified.'),
            _buildSampleChip('Booster Pump LOTO Bypass', 'Electrician attempted motor repair on Booster Pump P-204 while breaker was energized without physical LOTO padlock.'),
            _buildSampleChip('Derrick Harness Unhooked', 'Floorman unhooked full-body harness lanyard while maneuvering pipe racking board at 18 meters elevation without secondary lifeline.'),
            _buildSampleChip('Gas Manifold Flange Leak', 'Severe hydrocarbon gas hissing was detected at 6-inch manifold flange F-312 (45% LEL) while hot work grinding was ongoing within 10m.'),
          ],
        ),
        const SizedBox(height: 20),
        // Evidence Attachments & Location
        EnterpriseCard(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('EVIDENCE & METADATA', style: AppTypography.overline),
              const SizedBox(height: 10),
              Wrap(
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 12,
                runSpacing: 10,
                children: [
                  OutlinedButton.icon(
                    onPressed: () {
                      setState(() {
                        _attachedPhotos.add('photo_evidence_${_attachedPhotos.length + 1}.jpg');
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Simulated site photo attached.')),
                      );
                    },
                    icon: const Icon(Icons.camera_alt_outlined, size: 16),
                    label: Text(_attachedPhotos.isEmpty ? 'Attach Photo' : '${_attachedPhotos.length} Photo Attached'),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.location_on_outlined, size: 16, color: AppColors.primaryRed),
                      const SizedBox(width: 4),
                      Text('GPS Tagging', style: AppTypography.bodySmall),
                      Switch(
                        value: _isGpsEnabled,
                        activeThumbColor: AppColors.primaryRed,
                        onChanged: (v) => setState(() => _isGpsEnabled = v),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSampleChip(String label, String text) {
    return ActionChip(
      label: Text(label),
      backgroundColor: AppColors.surfaceSecondary,
      side: const BorderSide(color: AppColors.border),
      labelStyle: AppTypography.caption.copyWith(
        color: AppColors.textPrimary,
        fontWeight: FontWeight.w600,
      ),
      onPressed: () {
        setState(() {
          _observationController.text = text;
        });
      },
    );
  }

  // STEP 3: Operational Context
  Widget _buildStep3Context() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Step 3: Operational Context', style: AppTypography.sectionTitle),
        Text('Tag facility location, asset name, and operational unit', style: AppTypography.caption),
        const SizedBox(height: 16),
        Text('OPERATIONAL SITE', style: AppTypography.overline),
        const SizedBox(height: 6),
        DropdownButtonFormField<String>(
          initialValue: _selectedSite,
          isExpanded: true,
          decoration: const InputDecoration(),
          items: OilConstants.sites.map((s) {
            return DropdownMenuItem<String>(
              value: s['name'] as String,
              child: Text(
                s['name'] as String,
                style: AppTypography.bodyMedium,
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            );
          }).toList(),
          onChanged: (v) {
            if (v != null) setState(() => _selectedSite = v);
          },
        ),
        const SizedBox(height: 16),
        Text('FUNCTIONAL DEPARTMENT', style: AppTypography.overline),
        const SizedBox(height: 6),
        DropdownButtonFormField<String>(
          initialValue: _selectedDepartment,
          isExpanded: true,
          decoration: const InputDecoration(),
          items: OilConstants.departments.map((d) {
            return DropdownMenuItem<String>(
              value: d,
              child: Text(
                d,
                style: AppTypography.bodyMedium,
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            );
          }).toList(),
          onChanged: (v) {
            if (v != null) setState(() => _selectedDepartment = v);
          },
        ),
        const SizedBox(height: 16),
        Text('WORK ACTIVITY', style: AppTypography.overline),
        const SizedBox(height: 6),
        TextFormField(
          controller: _workActivityController,
          decoration: const InputDecoration(
            hintText: 'e.g. Turnaround Maintenance / Tripping Pipe',
          ),
        ),
        const SizedBox(height: 16),
        Text('EQUIPMENT / ASSET TAG', style: AppTypography.overline),
        const SizedBox(height: 6),
        TextFormField(
          controller: _equipmentController,
          decoration: const InputDecoration(
            hintText: 'e.g. Separator Vessel V-102 / Booster Pump P-204',
          ),
        ),
      ],
    );
  }

  // STEP 4: Review Before Analysis
  Widget _buildStep4Review() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Step 4: Confirm & Trigger AI Analysis', style: AppTypography.sectionTitle),
        Text('Review submission payload before running SIF NLP Engine', style: AppTypography.caption),
        const SizedBox(height: 16),
        EnterpriseCard(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('REPORT TYPE', style: AppTypography.overline),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.primaryRed.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      _selectedReportType,
                      style: AppTypography.caption.copyWith(
                        color: AppColors.primaryRed,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
              const Divider(height: 20),
              Text('OBSERVATION TEXT', style: AppTypography.overline),
              const SizedBox(height: 6),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.border),
                ),
                child: Text(
                  _observationController.text.trim().isNotEmpty
                      ? _observationController.text
                      : 'No text entered.',
                  style: AppTypography.bodyMedium,
                ),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('SITE', style: AppTypography.overline),
                        Text(_selectedSite, style: AppTypography.bodySmall.copyWith(fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('DEPARTMENT', style: AppTypography.overline),
                        Text(_selectedDepartment, style: AppTypography.bodySmall.copyWith(fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.infoBg,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.info.withValues(alpha: 0.3)),
          ),
          child: Row(
            children: [
              const Icon(Icons.auto_awesome, color: AppColors.info, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'SIF Sentinel NLP Engine will automatically extract hazards, identify barrier failures, score SIF potential, and generate explainable reasoning.',
                  style: AppTypography.caption.copyWith(color: AppColors.textPrimary),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          if (_currentStep > 0) ...[
            Expanded(
              child: CustomButton(
                label: 'Previous',
                variant: ButtonVariant.outlined,
                onPressed: () => setState(() => _currentStep--),
              ),
            ),
            const SizedBox(width: 12),
          ],
          Expanded(
            flex: 2,
            child: CustomButton(
              label: _currentStep == 3 ? 'Analyze with SIF Sentinel AI' : 'Continue',
              variant: ButtonVariant.primary,
              icon: _currentStep == 3 ? Icons.auto_awesome : Icons.arrow_forward_rounded,
              isLoading: _isAnalyzing,
              onPressed: () {
                if (_currentStep < 3) {
                  if (_currentStep == 1 && _observationController.text.trim().isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Please describe the observation before continuing.'),
                        backgroundColor: AppColors.critical,
                      ),
                    );
                    return;
                  }
                  setState(() => _currentStep++);
                } else {
                  _analyzeAndSubmit();
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
