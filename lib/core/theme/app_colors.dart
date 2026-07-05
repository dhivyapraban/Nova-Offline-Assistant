import 'package:flutter/material.dart';

/// Nothing OS inspired color palette for Nova Assistant
class NovaColors {
  NovaColors._();

  // === Primary Palette ===
  static const Color primary = Color(0xFF00FF88);
  static const Color primaryLight = Color(0xFF00C96A);
  static const Color primaryDark = Color(0xFF00FF88);

  // === Secondary Palette ===
  static const Color secondary = Color(0xFF00E5FF);
  static const Color secondaryLight = Color(0xFF00B8D4);
  static const Color secondaryDark = Color(0xFF00E5FF);

  // === Accent (from logo — Nova Red) ===
  static const Color accent = Color(0xFFFF1744);

  // === Dark Mode ===
  static const Color darkBackground = Color(0xFF0A0A0A);
  static const Color darkSurface = Color(0xFF141414);
  static const Color darkSurfaceVariant = Color(0xFF1E1E1E);
  static const Color darkSurfaceHigh = Color(0xFF262626);
  static const Color darkOnBackground = Color(0xFFE0E0E0);
  static const Color darkOnSurface = Color(0xFFCCCCCC);
  static const Color darkOnSurfaceVariant = Color(0xFF999999);
  static const Color darkOutline = Color(0xFF2A2A2A);
  static const Color darkOutlineVariant = Color(0xFF1A1A1A);

  // === Light Mode ===
  static const Color lightBackground = Color(0xFFFAFAFA);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightSurfaceVariant = Color(0xFFF0F0F0);
  static const Color lightSurfaceHigh = Color(0xFFE8E8E8);
  static const Color lightOnBackground = Color(0xFF1A1A1A);
  static const Color lightOnSurface = Color(0xFF333333);
  static const Color lightOnSurfaceVariant = Color(0xFF666666);
  static const Color lightOutline = Color(0xFFE0E0E0);
  static const Color lightOutlineVariant = Color(0xFFEEEEEE);

  // === Semantic Colors ===
  static const Color error = Color(0xFFFF5252);
  static const Color errorDark = Color(0xFFFF5252);
  static const Color errorLight = Color(0xFFD32F2F);
  static const Color success = Color(0xFF00E676);
  static const Color warning = Color(0xFFFFD600);
  static const Color info = Color(0xFF00B0FF);

  // === Note Colors ===
  static const List<Color> noteColors = [
    Color(0xFF1E1E1E), // Default dark
    Color(0xFF1B3A2A), // Dark green
    Color(0xFF1A2B3C), // Dark blue
    Color(0xFF3A1A2B), // Dark pink
    Color(0xFF3A2B1A), // Dark orange
    Color(0xFF2B1A3A), // Dark purple
    Color(0xFF1A3A3A), // Dark teal
    Color(0xFF3A3A1A), // Dark yellow
  ];

  // === Gradient Presets ===
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF00FF88), Color(0xFF00E5FF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient darkGradient = LinearGradient(
    colors: [Color(0xFF141414), Color(0xFF0A0A0A)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient accentGradient = LinearGradient(
    colors: [Color(0xFFFF1744), Color(0xFFFF6D00)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
