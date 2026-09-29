import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import 'custom_button.dart';

class EmptyStateWidget extends StatelessWidget {
  final String title;
  final String message;
  final IconData icon;
  final String? actionLabel;
  final VoidCallback? onAction;

  const EmptyStateWidget({
    super.key,
    required this.title,
    required this.message,
    this.icon = Icons.inbox_outlined,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: AppColors.surfaceSecondary,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.border),
              ),
              child: Icon(icon, size: 30, color: AppColors.textTertiary),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: AppTypography.headingMedium.copyWith(fontSize: 18),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            Text(
              message,
              style: AppTypography.bodySmall,
              textAlign: TextAlign.center,
            ),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 20),
              CustomButton(
                label: actionLabel!,
                onPressed: onAction,
                variant: ButtonVariant.outlined,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
