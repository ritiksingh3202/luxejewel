import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app_colors.dart';

class AppTheme {
  static const _inter = 'Outfit';
  static const _playfair = 'Outfit';

  static ThemeData dark() {
    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      fontFamily: _inter,
    );

    final colorScheme = const ColorScheme.dark(
      surface: AppColors.bgSecondary,
      onSurface: AppColors.textPrimary,
      primary: AppColors.gold,
      onPrimary: AppColors.bgPrimary,
      secondary: AppColors.divider,
      onSecondary: AppColors.textPrimary,
      error: AppColors.destructive,
      onError: AppColors.textPrimary,
      outline: AppColors.divider,
    );

    TextStyle playfair(TextStyle? s) =>
        (s ?? const TextStyle()).copyWith(fontFamily: _playfair, color: AppColors.textPrimary);

    final textTheme = base.textTheme.copyWith(
      displayLarge: playfair(base.textTheme.displayLarge).copyWith(color: AppColors.gold),
      displayMedium: playfair(base.textTheme.displayMedium).copyWith(color: AppColors.gold),
      displaySmall: playfair(base.textTheme.displaySmall).copyWith(color: AppColors.gold),
      headlineLarge: playfair(base.textTheme.headlineLarge),
      headlineMedium: playfair(base.textTheme.headlineMedium),
      headlineSmall: playfair(base.textTheme.headlineSmall),
      titleLarge: playfair(base.textTheme.titleLarge),
      titleMedium: base.textTheme.titleMedium?.copyWith(color: AppColors.textPrimary),
      bodyLarge: base.textTheme.bodyLarge?.copyWith(color: AppColors.textPrimary),
      bodyMedium: base.textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
      bodySmall: base.textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
      labelLarge: base.textTheme.labelLarge?.copyWith(
        color: AppColors.textPrimary,
        fontWeight: FontWeight.w600,
      ),
    );

    return base.copyWith(
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.bgPrimary,
      splashFactory: InkSparkle.splashFactory,
      textTheme: textTheme,
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.bgPrimary,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.light,
      ),
      dividerColor: AppColors.divider,
      cardTheme: CardThemeData(
        color: AppColors.bgSecondary,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.divider, width: 1),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.bgSecondary,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.divider),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.divider),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.gold, width: 1.5),
        ),
        labelStyle: textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
        hintStyle: textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.gold,
          foregroundColor: AppColors.bgPrimary,
          disabledBackgroundColor: AppColors.divider,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          textStyle: textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.gold,
          side: const BorderSide(color: AppColors.gold, width: 2),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          textStyle: textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.bgSecondary,
        indicatorColor: AppColors.gold.withOpacity(0.15),
        labelTextStyle: WidgetStateProperty.all(
          textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w500),
        ),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return IconThemeData(
            color: selected ? AppColors.gold : AppColors.textSecondary,
            size: 24,
          );
        }),
      ),
    );
  }
}
