import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app_colors.dart';
import 'app_typography.dart';

/// Material 3 theme configuration for Nova Assistant
class NovaTheme {
  NovaTheme._();

  // === Dark Theme ===
  static ThemeData get darkTheme {
    final colorScheme = ColorScheme.dark(
      primary: NovaColors.primaryDark,
      onPrimary: NovaColors.darkBackground,
      secondary: NovaColors.secondaryDark,
      onSecondary: NovaColors.darkBackground,
      tertiary: NovaColors.accent,
      surface: NovaColors.darkSurface,
      onSurface: NovaColors.darkOnSurface,
      surfaceContainerHighest: NovaColors.darkSurfaceVariant,
      error: NovaColors.errorDark,
      onError: Colors.white,
      outline: NovaColors.darkOutline,
      outlineVariant: NovaColors.darkOutlineVariant,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: colorScheme,
      textTheme: NovaTypography.textTheme.apply(
        bodyColor: NovaColors.darkOnSurface,
        displayColor: NovaColors.darkOnBackground,
      ),
      scaffoldBackgroundColor: NovaColors.darkBackground,
      appBarTheme: AppBarTheme(
        backgroundColor: NovaColors.darkBackground,
        foregroundColor: NovaColors.darkOnBackground,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        titleTextStyle: NovaTypography.textTheme.titleLarge?.copyWith(
          color: NovaColors.darkOnBackground,
        ),
      ),
      cardTheme: CardThemeData(
        color: NovaColors.darkSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: NovaColors.darkOutline, width: 1),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: NovaColors.primaryDark,
        foregroundColor: NovaColors.darkBackground,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: NovaColors.darkSurfaceVariant,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: NovaColors.darkOutline, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: NovaColors.primaryDark, width: 2),
        ),
        hintStyle: NovaTypography.textTheme.bodyMedium?.copyWith(
          color: NovaColors.darkOnSurfaceVariant,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: NovaColors.darkSurface,
        selectedItemColor: NovaColors.primaryDark,
        unselectedItemColor: NovaColors.darkOnSurfaceVariant,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: NovaColors.darkSurfaceVariant,
        selectedColor: NovaColors.primaryDark.withValues(alpha: 0.2),
        labelStyle: NovaTypography.textTheme.labelMedium!,
        side: BorderSide(color: NovaColors.darkOutline),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return NovaColors.primaryDark;
          }
          return NovaColors.darkOnSurfaceVariant;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return NovaColors.primaryDark.withValues(alpha: 0.3);
          }
          return NovaColors.darkOutline;
        }),
      ),
      dividerTheme: DividerThemeData(
        color: NovaColors.darkOutline,
        thickness: 1,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: NovaColors.darkSurfaceHigh,
        contentTextStyle: NovaTypography.textTheme.bodyMedium?.copyWith(
          color: NovaColors.darkOnSurface,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        behavior: SnackBarBehavior.floating,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: NovaColors.darkSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: NovaColors.darkSurface,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: NovaColors.primaryDark,
        linearTrackColor: NovaColors.darkOutline,
      ),
      sliderTheme: SliderThemeData(
        activeTrackColor: NovaColors.primaryDark,
        inactiveTrackColor: NovaColors.darkOutline,
        thumbColor: NovaColors.primaryDark,
        overlayColor: NovaColors.primaryDark.withValues(alpha: 0.1),
      ),
    );
  }

  // === Light Theme ===
  static ThemeData get lightTheme {
    final colorScheme = ColorScheme.light(
      primary: NovaColors.primaryLight,
      onPrimary: Colors.white,
      secondary: NovaColors.secondaryLight,
      onSecondary: Colors.white,
      tertiary: NovaColors.accent,
      surface: NovaColors.lightSurface,
      onSurface: NovaColors.lightOnSurface,
      surfaceContainerHighest: NovaColors.lightSurfaceVariant,
      error: NovaColors.errorLight,
      onError: Colors.white,
      outline: NovaColors.lightOutline,
      outlineVariant: NovaColors.lightOutlineVariant,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: colorScheme,
      textTheme: NovaTypography.textTheme.apply(
        bodyColor: NovaColors.lightOnSurface,
        displayColor: NovaColors.lightOnBackground,
      ),
      scaffoldBackgroundColor: NovaColors.lightBackground,
      appBarTheme: AppBarTheme(
        backgroundColor: NovaColors.lightBackground,
        foregroundColor: NovaColors.lightOnBackground,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        titleTextStyle: NovaTypography.textTheme.titleLarge?.copyWith(
          color: NovaColors.lightOnBackground,
        ),
      ),
      cardTheme: CardThemeData(
        color: NovaColors.lightSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: NovaColors.lightOutline, width: 1),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: NovaColors.primaryLight,
        foregroundColor: Colors.white,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: NovaColors.lightSurfaceVariant,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: NovaColors.lightOutline, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: NovaColors.primaryLight, width: 2),
        ),
        hintStyle: NovaTypography.textTheme.bodyMedium?.copyWith(
          color: NovaColors.lightOnSurfaceVariant,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: NovaColors.lightSurface,
        selectedItemColor: NovaColors.primaryLight,
        unselectedItemColor: NovaColors.lightOnSurfaceVariant,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: NovaColors.lightSurfaceVariant,
        selectedColor: NovaColors.primaryLight.withValues(alpha: 0.15),
        labelStyle: NovaTypography.textTheme.labelMedium!,
        side: BorderSide(color: NovaColors.lightOutline),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return NovaColors.primaryLight;
          }
          return NovaColors.lightOnSurfaceVariant;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return NovaColors.primaryLight.withValues(alpha: 0.3);
          }
          return NovaColors.lightOutline;
        }),
      ),
      dividerTheme: DividerThemeData(
        color: NovaColors.lightOutline,
        thickness: 1,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: NovaColors.lightOnBackground,
        contentTextStyle: NovaTypography.textTheme.bodyMedium?.copyWith(
          color: NovaColors.lightBackground,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        behavior: SnackBarBehavior.floating,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: NovaColors.lightSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: NovaColors.lightSurface,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: NovaColors.primaryLight,
        linearTrackColor: NovaColors.lightOutline,
      ),
      sliderTheme: SliderThemeData(
        activeTrackColor: NovaColors.primaryLight,
        inactiveTrackColor: NovaColors.lightOutline,
        thumbColor: NovaColors.primaryLight,
        overlayColor: NovaColors.primaryLight.withValues(alpha: 0.1),
      ),
    );
  }
}
