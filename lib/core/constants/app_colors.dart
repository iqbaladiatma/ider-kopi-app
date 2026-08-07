import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Signature Palette from mockup.html
  static const Color red = Color(0xFFE11D2E);
  static const Color redDark = Color(0xFFA10E1E);
  static const Color redLight = Color(0xFFFDECEE);
  static const Color ink = Color(0xFF101012);
  static const Color white = Color(0xFFFFFFFF);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceAlt = Color(0xFFF7F7F8);
  static const Color muted = Color(0xFF78767A);
  static const Color line = Color(0x14101012); // rgba(16,16,18,0.08)

  // Primary aliases
  static const Color primary = red;
  static const Color primaryDark = redDark;
  static const Color primaryLight = redLight;

  // Text colors
  static const Color textPrimary = ink;
  static const Color textSecondary = Color(0xFF4A5568);
  static const Color textMuted = muted;
  static const Color textLight = Color(0xFFCBD5E0);

  // Borders
  static const Color border = Color(0x14101012);
  static const Color borderLight = Color(0xFFECECEE);

  // Status colors from mockup.html
  static const Color green = Color(0xFF15803D);
  static const Color greenBg = Color(0xFFE6F4EA);
  static const Color success = green;
  static const Color successLight = greenBg;

  static const Color amber = Color(0xFFB45309);
  static const Color amberBg = Color(0xFFFBF0DE);
  static const Color warning = amber;
  static const Color warningLight = amberBg;

  static const Color primaryLighter = redLight;

  // Grays
  static const Color gray100 = Color(0xFFF3F4F6);
  static const Color gray300 = Color(0xFFD1D5DB);

  // Dark variant aliases for status
  static const Color successDark = green;
  static const Color warningDark = amber;
  static const Color errorDark = redDark;

  static const Color error = red;
  static const Color errorLight = redLight;

  static const Color background = surfaceAlt;
  static const Color gray900 = Color(0xFF111827);

  // Shadow definitions
  static const Color cardShadow = Color(0x14101012);
  static const BoxShadow softShadow = BoxShadow(
    color: Color(0x12101012),
    blurRadius: 18,
    offset: Offset(0, 8),
  );
  static const BoxShadow floatingShadow = BoxShadow(
    color: Color(0x2E101012),
    blurRadius: 30,
    offset: Offset(0, 14),
  );
  static const BoxShadow buttonShadow = BoxShadow(
    color: Color(0x2E101012),
    blurRadius: 12,
    offset: Offset(0, 4),
  );
  static const BoxShadow gradientShadow = BoxShadow(
    color: Color(0x33E11D2E),
    blurRadius: 16,
    offset: Offset(0, 6),
  );

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFFE11D2E), Color(0xFFA10E1E)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient headerGradient = LinearGradient(
    colors: [Color(0xFFE11D2E), Color(0xFFA10E1E)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient darkHeaderGradient = LinearGradient(
    colors: [Color(0xFF101012), Color(0xFF1C1C20)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}
