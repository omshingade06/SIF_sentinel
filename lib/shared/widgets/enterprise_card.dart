import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class EnterpriseCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color? backgroundColor;
  final BorderSide? border;
  final VoidCallback? onTap;
  final Color? indicatorColor;
  final BorderRadius? borderRadius;

  const EnterpriseCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.backgroundColor,
    this.border,
    this.onTap,
    this.indicatorColor,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final radius = borderRadius ?? BorderRadius.circular(12);

    Widget content = Container(
      decoration: BoxDecoration(
        color: backgroundColor ?? AppColors.surface,
        borderRadius: radius,
        border: Border.fromBorderSide(
          border ?? const BorderSide(color: AppColors.border, width: 1),
        ),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadow,
            offset: Offset(0, 2),
            blurRadius: 6,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: radius,
        child: Stack(
          children: [
            Padding(
              padding: indicatorColor != null
                  ? (padding is EdgeInsets
                      ? (padding as EdgeInsets).copyWith(left: (padding as EdgeInsets).left + 4)
                      : padding)
                  : padding,
              child: child,
            ),
            if (indicatorColor != null)
              Positioned(
                left: 0,
                top: 0,
                bottom: 0,
                width: 4,
                child: Container(color: indicatorColor),
              ),
          ],
        ),
      ),
    );

    if (onTap != null) {
      return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: radius,
          child: content,
        ),
      );
    }

    return content;
  }
}
