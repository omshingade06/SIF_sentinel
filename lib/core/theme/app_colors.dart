import 'package:flutter/material.dart';

/// Official Oil India Limited (OIL) Brand Colors & Design System Palette
class AppColors {
  AppColors._();

  // Official OIL Brand Colors
  static const Color primaryRed = Color(0xFFE31E24);
  static const Color primaryBlack = Color(0xFF2B2A29);

  // Background & Surfaces
  static const Color background = Color(0xFFF7F8FA);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceSecondary = Color(0xFFF1F3F5);
  static const Color darkSurface = Color(0xFF1F2023);
  static const Color darkCard = Color(0xFF26282C);

  // Typography / Text Colors
  static const Color textPrimary = Color(0xFF2B2A29);
  static const Color textSecondary = Color(0xFF687078);
  static const Color textTertiary = Color(0xFF9AA2A9);
  static const Color textLight = Color(0xFFFFFFFF);
  static const Color textLightMuted = Color(0xFFB0B7BE);

  // UI Borders & Dividers
  static const Color border = Color(0xFFE2E5E8);
  static const Color borderDark = Color(0xFF373A40);
  static const Color divider = Color(0xFFECEEF0);

  // Enterprise Status & SIF Risk Spectrum
  static const Color critical = Color(0xFFC62828); // Critical SIF Precursor
  static const Color criticalBg = Color(0xFFFDE8E8);
  static const Color high = Color(0xFFE65100); // High SIF Potential
  static const Color highBg = Color(0xFFFFF0E6);
  static const Color medium = Color(0xFFF59E0B); // Medium Risk
  static const Color mediumBg = Color(0xFFFEF3C7);
  static const Color low = Color(0xFF16834B); // Low Risk / Safe
  static const Color lowBg = Color(0xFFE8F5E9);

  // Action & System Informational
  static const Color info = Color(0xFF2563EB);
  static const Color infoBg = Color(0xFFEFF6FF);
  static const Color purple = Color(0xFF7C3AED);
  static const Color purpleBg = Color(0xFFF3E8FF);
  static const Color teal = Color(0xFF0D9488);
  static const Color tealBg = Color(0xFFCCFBF1);

  // Highlight Spans (for Explainable AI text evidence)
  static const Color highlightYellow = Color(0xFFFFEB3B);
  static const Color highlightYellowBg = Color(0xFFFFF9C4);
  static const Color highlightRedBg = Color(0xFFFFEBEE);

  // Shadow Colors
  static const Color shadow = Color(0x0A000000);
  static const Color shadowMedium = Color(0x14000000);
}
