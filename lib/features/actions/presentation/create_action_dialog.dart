import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/constants/oil_constants.dart';
import '../../../shared/models/corrective_action_model.dart';
import '../../../shared/models/report_model.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../reports/providers/reports_provider.dart';

class CreateActionDialog extends ConsumerStatefulWidget {
  final ReportModel? relatedReport;
  final String? defaultTitle;

  const CreateActionDialog({
    super.key,
    this.relatedReport,
    this.defaultTitle,
  });

  @override
  ConsumerState<CreateActionDialog> createState() => _CreateActionDialogState();
}

class _CreateActionDialogState extends ConsumerState<CreateActionDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descController;
  String _selectedAssignee = 'Biren Gogoi (Site Supervisor)';
  String _selectedSite = 'Duliajan Main Complex';
  ActionPriority _selectedPriority = ActionPriority.high;
  final int _daysDue = 2;

  final List<Map<String, String>> _supervisors = [
    {'name': 'Biren Gogoi', 'role': 'Site/Field Supervisor', 'display': 'Biren Gogoi (Site Supervisor)'},
    {'name': 'Suraj Dutta', 'role': 'Senior Electrical Engineer', 'display': 'Suraj Dutta (Senior Electrical Engineer)'},
    {'name': 'Debojit Hazarika', 'role': 'Drilling Supervisor', 'display': 'Debojit Hazarika (Drilling Supervisor)'},
    {'name': 'Hemen Das', 'role': 'Production Engineer', 'display': 'Hemen Das (Production Engineer)'},
    {'name': 'Rupok Sonowal', 'role': 'Yard Supervisor', 'display': 'Rupok Sonowal (Yard Supervisor)'},
  ];

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.defaultTitle ?? '');
    _descController = TextEditingController(
      text: widget.relatedReport != null
          ? 'Mitigation required for observation #${widget.relatedReport!.id}: ${widget.relatedReport!.observationText}'
          : '',
    );
    if (widget.relatedReport != null) {
      _selectedSite = widget.relatedReport!.site;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  void _submitAction() {
    if (!_formKey.currentState!.validate()) return;

    final supervisor = _supervisors.firstWhere(
      (s) => s['display'] == _selectedAssignee,
      orElse: () => _supervisors.first,
    );

    final newAction = CorrectiveActionModel(
      id: 'ACT-OIL-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}',
      reportId: widget.relatedReport?.id ?? 'OIL-2026-MANUAL',
      title: _titleController.text.trim(),
      description: _descController.text.trim(),
      assignedToName: supervisor['name']!,
      assignedToRole: supervisor['role']!,
      site: _selectedSite,
      priority: _selectedPriority,
      status: ActionStatus.assigned,
      progress: 0.1,
      dueDate: DateTime.now().add(Duration(days: _daysDue)),
      createdAt: DateTime.now(),
    );

    ref.read(actionsProvider.notifier).addAction(newAction);

    if (widget.relatedReport != null) {
      ref.read(reportsProvider.notifier).updateReportStatus(
            widget.relatedReport!.id,
            ReportStatus.actionAssigned,
          );
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Corrective Action #${newAction.id} assigned to ${newAction.assignedToName}.'),
        backgroundColor: AppColors.primaryBlack,
      ),
    );

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 520, maxHeight: 720),
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
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
                    child: const Icon(Icons.add_task_rounded, color: AppColors.primaryRed, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Create Corrective Action', style: AppTypography.headingMedium.copyWith(fontSize: 18)),
                        Text('Assign closed-loop safety intervention', style: AppTypography.caption),
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
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('ACTION TITLE', style: AppTypography.overline),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: _titleController,
                        decoration: const InputDecoration(
                          hintText: 'e.g. Enforce 4-gas testing protocol on Separator V-102',
                        ),
                        validator: (v) => (v == null || v.trim().isEmpty) ? 'Please enter an action title' : null,
                      ),
                      const SizedBox(height: 16),
                      Text('DESCRIPTION & SCOPE', style: AppTypography.overline),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: _descController,
                        maxLines: 3,
                        decoration: const InputDecoration(
                          hintText: 'Provide detailed instructions, barrier requirements, and verification steps...',
                        ),
                        validator: (v) => (v == null || v.trim().isEmpty) ? 'Please enter description' : null,
                      ),
                      const SizedBox(height: 16),
                      Text('ASSIGN TO SUPERVISOR / ENGINEER', style: AppTypography.overline),
                      const SizedBox(height: 6),
                      DropdownButtonFormField<String>(
                        initialValue: _selectedAssignee,
                        isExpanded: true,
                        decoration: const InputDecoration(),
                        items: _supervisors.map((s) {
                          return DropdownMenuItem<String>(
                            value: s['display']!,
                            child: Text(
                              s['display']!,
                              style: AppTypography.bodySmall,
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          );
                        }).toList(),
                        onChanged: (v) {
                          if (v != null) setState(() => _selectedAssignee = v);
                        },
                      ),
                      const SizedBox(height: 16),
                      LayoutBuilder(
                        builder: (context, constraints) {
                          final isCompact = constraints.maxWidth < 360;
                          final siteField = Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('OPERATIONAL SITE', style: AppTypography.overline, overflow: TextOverflow.ellipsis, maxLines: 1),
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
                                      style: AppTypography.bodySmall,
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                    ),
                                  );
                                }).toList(),
                                onChanged: (v) {
                                  if (v != null) setState(() => _selectedSite = v);
                                },
                              ),
                            ],
                          );

                          final priorityField = Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('PRIORITY', style: AppTypography.overline, overflow: TextOverflow.ellipsis, maxLines: 1),
                              const SizedBox(height: 6),
                              DropdownButtonFormField<ActionPriority>(
                                initialValue: _selectedPriority,
                                isExpanded: true,
                                decoration: const InputDecoration(),
                                items: ActionPriority.values.map((p) {
                                  return DropdownMenuItem<ActionPriority>(
                                    value: p,
                                    child: Text(
                                      p.label,
                                      style: AppTypography.bodySmall,
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                    ),
                                  );
                                }).toList(),
                                onChanged: (v) {
                                  if (v != null) setState(() => _selectedPriority = v);
                                },
                              ),
                            ],
                          );

                          if (isCompact) {
                            return Column(
                              children: [
                                siteField,
                                const SizedBox(height: 12),
                                priorityField,
                              ],
                            );
                          }

                          return Row(
                            children: [
                              Expanded(child: siteField),
                              const SizedBox(width: 10),
                              Expanded(child: priorityField),
                            ],
                          );
                        },
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
                      label: 'Assign Action',
                      variant: ButtonVariant.primary,
                      icon: Icons.check_circle_outline_rounded,
                      onPressed: _submitAction,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
