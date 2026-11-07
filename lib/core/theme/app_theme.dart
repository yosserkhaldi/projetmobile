import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_palette.dart';

export 'app_palette.dart';

abstract final class AppRadius {
  static const sm = 8.0, md = 12.0, input = 14.0, button = 16.0;
  static const card = 20.0, hero = 28.0, pill = 99.0;
}

abstract final class AppFonts {
  static const body = 'Manrope';
  static const display = 'BricolageGrotesque';
  static const mono = 'JetBrainsMono';
}

/// Thèmes clair et sombre, construits à partir de [AppPalette].
abstract final class AppTheme {
  static ThemeData get light => _build(AppPalette.light, Brightness.light);
  static ThemeData get dark => _build(AppPalette.dark, Brightness.dark);

  static ThemeData _build(AppPalette p, Brightness brightness) {
    final scheme =
        ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          brightness: brightness,
        ).copyWith(
          primary: p.primary,
          onPrimary: Colors.white,
          primaryContainer: p.primaryTint,
          onPrimaryContainer: p.primaryText,
          secondary: AppColors.accent,
          onSecondary: AppColors.ink,
          surface: p.surface,
          onSurface: p.text,
          onSurfaceVariant: p.textMuted,
          surfaceContainerHighest: p.surfaceAlt,
          surfaceContainerHigh: p.surface,
          surfaceContainer: p.surface,
          surfaceContainerLow: p.surface,
          outline: p.border,
          outlineVariant: p.borderSoft,
          error: brightness == Brightness.light
              ? AppColors.errorSolid
              : p.errorText,
        );
    final title = TextStyle(
      fontFamily: AppFonts.display,
      fontWeight: FontWeight.w800,
      color: p.text,
    );
    final buttonShape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppRadius.button),
    );
    const buttonText = TextStyle(
      fontFamily: AppFonts.body,
      fontSize: 16,
      fontWeight: FontWeight.w800,
    );
    OutlineInputBorder inputBorder(Color color) => OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppRadius.input),
      borderSide: BorderSide(color: color, width: 1.5),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      fontFamily: AppFonts.body,
      scaffoldBackgroundColor: p.canvas,
      canvasColor: p.canvas,
      extensions: [p],
      textTheme: TextTheme(
        headlineLarge: title,
        headlineMedium: title,
        headlineSmall: title,
        titleLarge: title,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: p.canvas,
        foregroundColor: p.text,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: TextStyle(
          fontFamily: AppFonts.display,
          fontWeight: FontWeight.w800,
          fontSize: 20,
          letterSpacing: -0.3,
          color: p.text,
        ),
      ),
      cardTheme: CardThemeData(
        color: p.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          side: BorderSide(color: p.borderSoft),
          borderRadius: BorderRadius.circular(AppRadius.card),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: p.surface,
        hintStyle: TextStyle(color: p.textMuted),
        border: inputBorder(p.border),
        enabledBorder: inputBorder(p.border),
        focusedBorder: inputBorder(p.primaryText),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(64, 56),
          shape: buttonShape,
          textStyle: buttonText,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(64, 56),
          foregroundColor: p.text,
          side: BorderSide(color: p.text, width: 1.5),
          shape: buttonShape,
          textStyle: buttonText,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: p.primaryText),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: p.surface,
        indicatorColor: p.primaryTint,
        iconTheme: WidgetStateProperty.resolveWith(
          (states) => IconThemeData(
            color: states.contains(WidgetState.selected)
                ? p.primaryText
                : p.textMuted,
          ),
        ),
        labelTextStyle: WidgetStateProperty.resolveWith(
          (states) => TextStyle(
            fontSize: 11,
            fontWeight: states.contains(WidgetState.selected)
                ? FontWeight.w800
                : FontWeight.w700,
            color: states.contains(WidgetState.selected)
                ? p.primaryText
                : p.textMuted,
          ),
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: p.canvas,
        surfaceTintColor: Colors.transparent,
        dragHandleColor: p.border,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: p.surface,
        surfaceTintColor: Colors.transparent,
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: brightness == Brightness.light
            ? AppColors.ink
            : p.surfaceAlt,
        contentTextStyle: TextStyle(
          color: brightness == Brightness.light ? Colors.white : p.text,
          fontWeight: FontWeight.w700,
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: p.surface,
        side: BorderSide(color: p.border),
        labelStyle: TextStyle(color: p.text, fontWeight: FontWeight.w700),
      ),
      listTileTheme: ListTileThemeData(iconColor: p.primaryText),
      dividerColor: p.borderSoft,
    );
  }
}
