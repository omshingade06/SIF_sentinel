import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';

enum ButtonVariant { primary, secondary, outlined, danger, text }

class CustomButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final ButtonVariant variant;
  final bool isLoading;
  final double? width;
  final EdgeInsetsGeometry padding;

  const CustomButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.variant = ButtonVariant.primary,
    this.isLoading = false,
    this.width,
    this.padding = const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
  });

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color fg;
    BorderSide side = BorderSide.none;

    switch (variant) {
      case ButtonVariant.primary:
        bg = AppColors.primaryRed;
        fg = Colors.white;
        break;
      case ButtonVariant.secondary:
        bg = AppColors.primaryBlack;
        fg = Colors.white;
        break;
      case ButtonVariant.outlined:
        bg = Colors.transparent;
        fg = AppColors.textPrimary;
        side = const BorderSide(color: AppColors.border, width: 1.2);
        break;
      case ButtonVariant.danger:
        bg = AppColors.critical;
        fg = Colors.white;
        break;
      case ButtonVariant.text:
        bg = Colors.transparent;
        fg = AppColors.primaryRed;
        break;
    }

    Widget content = Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (isLoading) ...[
          SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(fg),
            ),
          ),
          const SizedBox(width: 8),
        ] else if (icon != null) ...[
          Icon(icon, size: 17, color: fg),
          const SizedBox(width: 6),
        ],
        Flexible(
          child: Text(
            label,
            style: AppTypography.bodyMedium.copyWith(
              color: fg,
              fontWeight: FontWeight.w600,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );

    final btn = ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: bg,
        foregroundColor: fg,
        elevation: 0,
        padding: padding,
        side: side,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      child: content,
    );

    if (width != null) {
      return SizedBox(width: width, child: btn);
    }
    return btn;
  }
}
