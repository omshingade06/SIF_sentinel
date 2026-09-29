import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../features/auth/providers/auth_provider.dart';
import '../../features/demo/presentation/sih_demo_dialog.dart';

class OilHeader extends ConsumerWidget implements PreferredSizeWidget {
  final String title;
  final String? subtitle;
  final List<Widget>? actions;
  final bool showRoleBadge;
  final bool showSimulatorButton;

  const OilHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.actions,
    this.showRoleBadge = true,
    this.showSimulatorButton = true,
  });

  @override
  Size get preferredSize => const Size.fromHeight(56);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);

    final canPop = ModalRoute.of(context)?.canPop ?? false;

    return AppBar(
      backgroundColor: AppColors.surface,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      titleSpacing: canPop ? 0 : 12,
      title: Row(
        children: [
          if (!canPop) ...[
            // SIF Sentinel App Icon Emblem on top-level pages
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: Image.asset(
                'assets/images/app_icon.png',
                width: 28,
                height: 28,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 8),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: Text(
                        title,
                        style: AppTypography.headingMedium.copyWith(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                    if (showRoleBadge) ...[
                      const SizedBox(width: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceSecondary,
                          borderRadius: BorderRadius.circular(3),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Text(
                          authState.user.userRole.displayName.split(' ').first.toUpperCase(),
                          style: AppTypography.overline.copyWith(
                            color: AppColors.textSecondary,
                            fontSize: 8,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                if (subtitle != null)
                  Text(
                    subtitle!,
                    style: AppTypography.caption.copyWith(
                      color: AppColors.textSecondary,
                      fontSize: 10,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        if (showSimulatorButton)
          Padding(
            padding: const EdgeInsets.only(right: 4),
            child: InkWell(
              onTap: () {
                showDialog(
                  context: context,
                  builder: (ctx) => const SihDemoDialog(),
                );
              },
              borderRadius: BorderRadius.circular(6),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primaryRed.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: AppColors.primaryRed.withValues(alpha: 0.35)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.science_outlined, size: 13, color: AppColors.primaryRed),
                    const SizedBox(width: 3),
                    Text(
                      'AI Lab',
                      style: AppTypography.caption.copyWith(
                        color: AppColors.primaryRed,
                        fontWeight: FontWeight.w700,
                        fontSize: 10.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        if (actions != null) ...actions!,
        const SizedBox(width: 4),
      ],
      bottom: const PreferredSize(
        preferredSize: Size.fromHeight(1),
        child: Divider(height: 1, color: AppColors.border),
      ),
    );
  }
}
