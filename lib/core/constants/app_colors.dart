import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Brand scale — Rich crimson red palette
  static const Color brand50 = Color(0xFFFFF1F2);
  static const Color brand100 = Color(0xFFFFE4E6);
  static const Color brand200 = Color(0xFFFFCDD1);
  static const Color brand300 = Color(0xFFFCA5AB);
  static const Color brand400 = Color(0xFFF86D78);
  static const Color brand500 = Color(0xFFF03D4E);
  static const Color brand600 = Color(0xFFDC2030);
  static const Color brand700 = Color(0xFFB91424);
  static const Color brand800 = Color(0xFF991222);
  static const Color brand900 = Color(0xFF7F1020);

  // Primary aliases
  static const Color primary = brand600;
  static const Color primaryDark = brand700;
  static const Color primaryLight = brand100;
  static const Color primaryLighter = brand50;

  // Accent — warm gold for contrast
  static const Color accent = Color(0xFFFF6B35);
  static const Color accentLight = Color(0xFFFFF0EB);

  // Backgrounds & surfaces
  static const Color background = Color(0xFFFCFCFD);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceAlt = Color(0xFFF7F8FA);
  static const Color surfaceElevated = Color(0xFFFFFFFF);

  // Text
  static const Color textPrimary = Color(0xFF0D1117);
  static const Color textSecondary = Color(0xFF4A5568);
  static const Color textMuted = Color(0xFF9AA5B4);
  static const Color textLight = Color(0xFFCBD5E0);

  // Border
  static const Color border = Color(0xFFE8ECF0);
  static const Color borderLight = Color(0xFFF0F3F6);

  // Status colors
  static const Color success = Color(0xFF0F9960);
  static const Color successLight = Color(0xFFD4F5E9);
  static const Color successDark = Color(0xFF0A7A4A);
  static const Color warning = Color(0xFFE5A20B);
  static const Color warningLight = Color(0xFFFFF4CC);
  static const Color warningDark = Color(0xFFBF880A);
  static const Color error = Color(0xFFDC2030);
  static const Color errorLight = Color(0xFFFFE4E6);
  static const Color errorDark = Color(0xFFB91424);
  static const Color info = Color(0xFF2B6CB0);
  static const Color infoLight = Color(0xFFEBF4FF);

  // Gray scale
  static const Color gray50 = Color(0xFFF7F8FA);
  static const Color gray100 = Color(0xFFEFF1F5);
  static const Color gray200 = Color(0xFFE2E6EC);
  static const Color gray300 = Color(0xFFCBD2DC);
  static const Color gray400 = Color(0xFF9AA5B4);
  static const Color gray500 = Color(0xFF677488);
  static const Color gray600 = Color(0xFF4A5568);
  static const Color gray700 = Color(0xFF374151);
  static const Color gray800 = Color(0xFF1F2937);
  static const Color gray900 = Color(0xFF0D1117);

  // Shadows
  static const Color cardShadow = Color(0x0A000000);
  static const Color buttonShadow = Color(0x28DC2030);
  static const Color gradientShadow = Color(0x40DC2030);

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFFDC2030), Color(0xFF991222)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient primaryGradientVertical = LinearGradient(
    colors: [Color(0xFFE8273A), Color(0xFFB91424)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient warmGradient = LinearGradient(
    colors: [Color(0xFFDC2030), Color(0xFFFF6B35)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient headerGradient = LinearGradient(
    colors: [Color(0xFFB91424), Color(0xFF7F1020)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Dark mode
  static const Color darkBackground = Color(0xFF0A0E1A);
  static const Color darkSurface = Color(0xFF141824);
  static const Color darkBorder = Color(0xFF252D3D);
}
