import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Design tokens replicating the AVISENA COL reference app.
class AppColors {
  AppColors._();

  // Brand
  static const Color primary = Color(0xFF49E619);
  static const Color primaryHover = Color(0xFF3CD110);
  static const Color primarySoft = Color(0xFF5BE830);

  // Surfaces
  static const Color backgroundLight = Color(0xFFF6F8F6);
  static const Color backgroundDark = Color(0xFF070A14);
  static const Color sidebarDark = Color(0xFF0D121E);
  static const Color borderDark = Color(0xFF1C2A44);
  static const Color surfaceDark = Color(0xFF152111);

  // Sidebar (light)
  static const Color sidebarLight = Color(0xFFFFFFFF);
  static const Color borderLight = Color(0xFFE2E8F0);
  static const Color hoverLight = Color(0xFFF1F5F9);

  // Text
  static const Color textDark = Color(0xFF0F172A);
  static const Color textMuted = Color(0xFF64748B);
  static const Color textDarkTheme = Color(0xFFEFF1F5);
  static const Color textDarkThemeMuted = Color(0xFFBECBB3);

  // Semantic
  static const Color success = Color(0xFF16A34A);
  static const Color warning = Color(0xFFF59E0B);
  static const Color danger = Color(0xFFDC2626);
  static const Color info = Color(0xFF2563EB);
  static const Color emerald900 = Color(0xFF064E3B);
  static const Color emerald100 = Color(0xFFD0FAE5);
}

/// Shared radius / spacing constants.
class AppRadius {
  AppRadius._();
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
  static const double pill = 999;
}

class AppTheme {
  AppTheme._();

  static TextTheme _textTheme(Color body, Color display) {
    return GoogleFonts.interTextTheme().apply(
      bodyColor: body,
      displayColor: display,
    );
  }

  static ThemeData get lightTheme => _build(
        brightness: Brightness.light,
        scaffold: AppColors.backgroundLight,
        surface: Colors.white,
        onSurface: AppColors.textDark,
        border: AppColors.borderLight,
        muted: AppColors.textMuted,
      );

  static ThemeData get darkTheme => _build(
        brightness: Brightness.dark,
        scaffold: AppColors.backgroundDark,
        surface: AppColors.sidebarDark,
        onSurface: AppColors.textDarkTheme,
        border: AppColors.borderDark,
        muted: AppColors.textDarkThemeMuted,
      );

  static ThemeData _build({
    required Brightness brightness,
    required Color scaffold,
    required Color surface,
    required Color onSurface,
    required Color border,
    required Color muted,
  }) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: brightness,
      primary: AppColors.primary,
      onPrimary: Colors.black,
      surface: surface,
      onSurface: onSurface,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: scaffold,
      textTheme: _textTheme(onSurface, onSurface),
      dividerColor: border,
      appBarTheme: AppBarTheme(
        backgroundColor: surface,
        elevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(color: onSurface),
        titleTextStyle: TextStyle(
          color: onSurface,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),
      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.xl),
          side: BorderSide(color: border),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.black,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          textStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: onSurface,
          side: BorderSide(color: border),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primaryHover,
          textStyle: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: brightness == Brightness.light ? Colors.white : AppColors.borderDark,
        labelStyle: TextStyle(color: muted),
        hintStyle: TextStyle(color: muted),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: BorderSide(color: border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: BorderSide(color: border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
      dataTableTheme: DataTableThemeData(
        headingRowColor: WidgetStatePropertyAll(
          brightness == Brightness.light ? const Color(0xFFF8FAFC) : AppColors.borderDark,
        ),
        headingTextStyle: TextStyle(
          color: muted,
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.6,
        ),
        dataTextStyle: TextStyle(color: onSurface, fontSize: 13),
        dividerThickness: 0.6,
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? AppColors.primary
              : Colors.transparent,
        ),
        checkColor: const WidgetStatePropertyAll(Colors.black),
        side: BorderSide(color: muted),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      ),
      drawerTheme: DrawerThemeData(backgroundColor: surface),
    );
  }
}
