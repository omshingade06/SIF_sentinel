import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../shared/models/corrective_action_model.dart';
import '../../../shared/widgets/oil_header.dart';
import '../../../shared/widgets/enterprise_card.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../reports/providers/reports_provider.dart';
import 'create_action_dialog.dart';

class ActionCenterScreen extends ConsumerStatefulWidget {
  const ActionCenterScreen({super.key});

  @override
  ConsumerState<ActionCenterScreen> createState() => _ActionCenterScreenState();
}

class _ActionCenterScreenState extends ConsumerState<ActionCenterScreen> {
  String _selectedFilter = 'All';

  @override
  Widget build(BuildContext context) {
    final actions = ref.watch(actionsProvider);

    final filtered = actions.where((a) {
      if (_selectedFilter == 'All') return true;
      if (_selectedFilter == 'Assigned') return a.status == ActionStatus.assigned;
      if (_selectedFilter == 'In Progress') return a.status == ActionStatus.inProgress;
      if (_selectedFilter == 'Pending') return a.status == ActionStatus.pendingVerification;
      if (_selectedFilter == 'Completed') return a.status == ActionStatus.completed;
      if (_selectedFilter == 'Overdue') return a.status == ActionStatus.overdue;
      return true;
    }).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: OilHeader(
        title: 'Action Center',
        subtitle: '${actions.length} Total Corrective Interventions',
        actions: [
          IconButton(
            tooltip: 'New Action',
            icon: const Icon(Icons.add_task_rounded, color: AppColors.primaryRed),
            onPressed: () {
              showDialog(
                context: context,
                builder: (ctx) => const CreateActionDialog(),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter Tabs
          Container(
            color: AppColors.surface,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: ['All', 'In Progress', 'Assigned', 'Pending', 'Completed', 'Overdue'].map((filter) {
                  final isSelected = _selectedFilter == filter;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(filter),
                      selected: isSelected,
                      selectedColor: AppColors.primaryRed.withValues(alpha: 0.12),
                      side: BorderSide(
                        color: isSelected ? AppColors.primaryRed : AppColors.border,
                      ),
                      labelStyle: AppTypography.caption.copyWith(
                        color: isSelected ? AppColors.primaryRed : AppColors.textPrimary,
                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                      ),
                      onSelected: (val) {
                        if (val) setState(() => _selectedFilter = filter);
                      },
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          const Divider(height: 1),

          // List of Actions
          Expanded(
            child: filtered.isEmpty
                ? const EmptyStateWidget(
                    title: 'No Actions Found',
                    message: 'There are no corrective interventions in this category.',
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final item = filtered[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _buildActionCard(context, item),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard(BuildContext context, CorrectiveActionModel item) {
    Color statusColor = AppColors.info;
    if (item.status == ActionStatus.completed) statusColor = AppColors.low;
    if (item.status == ActionStatus.overdue) statusColor = AppColors.critical;
    if (item.status == ActionStatus.inProgress) statusColor = AppColors.medium;

    return EnterpriseCard(
      indicatorColor: item.priority == ActionPriority.critical ? AppColors.critical : AppColors.high,
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
                    Flexible(
                      child: Text(
                        item.id,
                        style: AppTypography.caption.copyWith(fontWeight: FontWeight.w700),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceSecondary,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text('Ref: ${item.reportId}', style: AppTypography.caption.copyWith(fontSize: 9.5)),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  item.status.label.toUpperCase(),
                  style: AppTypography.overline.copyWith(
                    color: statusColor,
                    fontWeight: FontWeight.w700,
                    fontSize: 9.5,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(item.title, style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 6),
          Text(
            item.description,
            style: AppTypography.bodySmall,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 12),

          // Progress Bar
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: item.progress,
                    minHeight: 6,
                    backgroundColor: AppColors.surfaceSecondary,
                    valueColor: AlwaysStoppedAnimation<Color>(statusColor),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                '${(item.progress * 100).toInt()}%',
                style: AppTypography.caption.copyWith(fontWeight: FontWeight.w700, color: statusColor),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.person_outline, size: 14, color: AppColors.textSecondary),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  item.assignedToName,
                  style: AppTypography.caption.copyWith(fontWeight: FontWeight.w600),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.event_outlined, size: 14, color: AppColors.textSecondary),
              const SizedBox(width: 4),
              Text('Due: ${DateFormat('MMM dd').format(item.dueDate)}', style: AppTypography.caption),
            ],
          ),
          if (item.closureVerificationNotes != null) ...[
            const Divider(height: 16),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.lowBg,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(
                children: [
                  const Icon(Icons.verified_rounded, size: 14, color: AppColors.low),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Verified: ${item.closureVerificationNotes}',
                      style: AppTypography.caption.copyWith(color: AppColors.low, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),
          ],
          const Divider(height: 16),
          // Action Buttons
          Row(
            children: [
              if (item.status != ActionStatus.completed) ...[
                Expanded(
                  child: CustomButton(
                    label: 'Update Progress',
                    variant: ButtonVariant.outlined,
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                    onPressed: () {
                      _showUpdateProgressDialog(context, item);
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: CustomButton(
                    label: 'Verify & Close',
                    variant: ButtonVariant.primary,
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                    onPressed: () {
                      ref.read(actionsProvider.notifier).updateActionStatus(
                            item.id,
                            ActionStatus.completed,
                            progress: 1.0,
                            verificationNotes: 'Site mitigation confirmed on-site by HSE Authority.',
                            verifiedByName: 'Safety Officer',
                          );
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Action marked as Completed & Verified.')),
                      );
                    },
                  ),
                ),
              ] else
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: null,
                    icon: const Icon(Icons.check_circle, size: 16, color: AppColors.low),
                    label: const Text('Verified & Closed', style: TextStyle(color: AppColors.low)),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  void _showUpdateProgressDialog(BuildContext context, CorrectiveActionModel item) {
    double tempProgress = item.progress;
    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: AppColors.surface,
              title: Text('Update Action Progress', style: AppTypography.headingMedium.copyWith(fontSize: 18)),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.title, style: AppTypography.bodySmall),
                  const SizedBox(height: 16),
                  Text('Progress: ${(tempProgress * 100).toInt()}%', style: AppTypography.bodyLarge.copyWith(fontWeight: FontWeight.w700)),
                  Slider(
                    value: tempProgress,
                    min: 0.0,
                    max: 1.0,
                    divisions: 10,
                    activeColor: AppColors.primaryRed,
                    onChanged: (val) {
                      setDialogState(() => tempProgress = val);
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    final newStatus = tempProgress >= 1.0 ? ActionStatus.completed : ActionStatus.inProgress;
                    ref.read(actionsProvider.notifier).updateActionStatus(
                          item.id,
                          newStatus,
                          progress: tempProgress,
                        );
                    Navigator.of(ctx).pop();
                  },
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
