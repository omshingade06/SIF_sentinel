import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// Clean professional typography scale using Google Fonts Inter (fallback Roboto)
class AppTypography {
  AppTypography._();

  static TextStyle displayLarge = GoogleFonts.inter(
    fontSize: 32,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.5,
    color: AppColors.textPrimary,
    height: 1.2,
  );

  static TextStyle displayMedium = GoogleFonts.inter(
    fontSize: 28,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.4,
    color: AppColors.textPrimary,
    height: 1.25,
  );

  static TextStyle headingLarge = GoogleFonts.inter(
    fontSize: 24,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.3,
    color: AppColors.textPrimary,
    height: 1.3,
  );

  static TextStyle headingMedium = GoogleFonts.inter(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.2,
    color: AppColors.textPrimary,
    height: 1.35,
  );

  static TextStyle sectionTitle = GoogleFonts.inter(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.1,
    color: AppColors.textPrimary,
    height: 1.4,
  );

  static TextStyle bodyLarge = GoogleFonts.inter(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimary,
    height: 1.5,
  );

  static TextStyle bodyMedium = GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
    height: 1.5,
  );

  static TextStyle bodySmall = GoogleFonts.inter(
    fontSize: 13,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
    height: 1.4,
  );

  static TextStyle caption = GoogleFonts.inter(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
    height: 1.35,
  );

  static TextStyle overline = GoogleFonts.inter(
    fontSize: 11,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.8,
    color: AppColors.textTertiary,
    height: 1.3,
  );

  static TextStyle mono = GoogleFonts.jetBrainsMono(
    fontSize: 13,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimary,
  );
}
