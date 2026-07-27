import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Brand scale (from tailwind.config.ts)
  static const Color brand50 = Color(0xFFFEF2F2);
  static const Color brand100 = Color(0xFFFEE2E2);
  static const Color brand200 = Color(0xFFFECACA);
  static const Color brand300 = Color(0xFFFCA5A5);
  static const Color brand400 = Color(0xFFF87171);
  static const Color brand500 = Color(0xFFEF4444);
  static const Color brand600 = Color(0xFFDC2626);
  static const Color brand700 = Color(0xFFB91C1C);
  static const Color brand800 = Color(0xFF991B1B);
  static const Color brand900 = Color(0xFF7F1D1D);

  // Primary aliases
  static const Color primary = brand600;
  static const Color primaryDark = brand700;
  static const Color primaryLight = brand100;
  static const Color primaryLighter = brand50;

  // Backgrounds & surfaces
  static const Color background = Color(0xFFFFFFFF);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceAlt = Color(0xFFF9FAFB);

  // Text
  static const Color textPrimary = Color(0xFF111827);
  static const Color textSecondary = Color(0xFF4B5563);
  static const Color textMuted = Color(0xFF9CA3AF);

  // Border
  static const Color border = Color(0xFFE5E7EB);

  // Status colors
  static const Color success = Color(0xFF16A34A);
  static const Color successLight = Color(0xFFDCFCE7);
  static const Color successDark = Color(0xFF15803D);
  static const Color warning = Color(0xFFF59E0B);
  static const Color warningLight = Color(0xFFFEF3C7);
  static const Color warningDark = Color(0xFFD97706);
  static const Color error = Color(0xFFEF4444);
  static const Color errorLight = Color(0xFFFEE2E2);
  static const Color errorDark = Color(0xFFDC2626);

  // Gray scale
  static const Color gray50 = Color(0xFFF9FAFB);
  static const Color gray100 = Color(0xFFF3F4F6);
  static const Color gray200 = Color(0xFFE5E7EB);
  static const Color gray300 = Color(0xFFD1D5DB);
  static const Color gray400 = Color(0xFF9CA3AF);
  static const Color gray500 = Color(0xFF6B7280);
  static const Color gray600 = Color(0xFF4B5563);
  static const Color gray700 = Color(0xFF374151);
  static const Color gray800 = Color(0xFF1F2937);
  static const Color gray900 = Color(0xFF111827);

  // Shadows
  static const Color cardShadow = Color(0x0A000000);
  static const Color buttonShadow = Color(0x1ADC2626);
  static const Color gradientShadow = Color(0x33DC2626);

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, primaryDark],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Dark mode placeholders (for future)
  static const Color darkBackground = Color(0xFF0F172A);
  static const Color darkSurface = Color(0xFF1E293B);
  static const Color darkBorder = Color(0xFF334155);
}
