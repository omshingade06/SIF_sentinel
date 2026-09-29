import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../shared/models/notification_model.dart';
import '../../../shared/widgets/oil_header.dart';
import '../../../shared/widgets/enterprise_card.dart';
import '../../../shared/widgets/sif_risk_badge.dart';
import '../../reports/providers/reports_provider.dart';
import '../../reports/presentation/report_detail_screen.dart';

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifications = ref.watch(notificationsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: OilHeader(
        title: 'Safety Alerts',
        subtitle: '${notifications.where((n) => !n.isRead).length} Unread Notifications',
        actions: [
          TextButton(
            onPressed: () {
              ref.read(notificationsProvider.notifier).markAllAsRead();
            },
            child: const Text('Mark all read', style: TextStyle(color: AppColors.primaryRed)),
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: notifications.length,
        itemBuilder: (context, index) {
          final item = notifications[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _buildNotificationCard(context, ref, item),
          );
        },
      ),
    );
  }

  Widget _buildNotificationCard(BuildContext context, WidgetRef ref, NotificationModel item) {
    Color iconBg = AppColors.criticalBg;
    Color iconColor = AppColors.critical;
    IconData icon = Icons.warning_amber_rounded;

    if (item.type == NotificationType.emergingRisk) {
      iconBg = AppColors.highBg;
      iconColor = AppColors.high;
      icon = Icons.auto_awesome;
    } else if (item.type == NotificationType.reportReviewed) {
      iconBg = AppColors.lowBg;
      iconColor = AppColors.low;
      icon = Icons.verified_user_rounded;
    }

    return EnterpriseCard(
      indicatorColor: item.isRead ? Colors.transparent : AppColors.primaryRed,
      onTap: () {
        ref.read(notificationsProvider.notifier).markAsRead(item.id);
        if (item.relatedReportId != null) {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (ctx) => ReportDetailScreen(reportId: item.relatedReportId!),
            ),
          );
        }
      },
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: iconBg, shape: BoxShape.circle),
            child: Icon(icon, size: 20, color: iconColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        item.title,
                        style: AppTypography.bodySmall.copyWith(
                          fontWeight: item.isRead ? FontWeight.w600 : FontWeight.w800,
                        ),
                      ),
                    ),
                    Text(
                      DateFormat('HH:mm').format(item.timestamp),
                      style: AppTypography.caption.copyWith(color: AppColors.textTertiary, fontSize: 10.5),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  item.message,
                  style: AppTypography.caption.copyWith(color: AppColors.textSecondary, fontSize: 12),
                ),
                if (item.sifPotential != null) ...[
                  const SizedBox(height: 8),
                  SifRiskBadge(potential: item.sifPotential!, size: BadgeSize.small),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
