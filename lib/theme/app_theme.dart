import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

// ─── GameArena Unified Professional Palette ──────────────────────────────────
class AppColors {
  // 1. Core Backgrounds (Matched strictly to Figma dark slate)
  static const bg0 = Color(0xFF12141D); // Main scaffold background
  static const bg1 = Color(0xFF191B26); // Modals / Surface layers
  static const bg2 = Color(0xFF1D1F2B); // Elevated components
  static const bg3 = Color(0xFF222432); // Input fields & flat buttons

  // 2. Brand Accents (Stripped the "rainbow", keeping only Figma colors)
  static const cyan =
      Color(0xFF5DE2E2); // All secondary buttons, success, icons
  static const pink = Color(0xFFF23D88); // Gradient end
  static const purple = Color(0xFF9D28B0); // Gradient start
  static const red =
      Color(0xFFFF4D4D); // Standard professional error (kept clean)
  static const green = Color(0xFF4CAF50); // Success and approved states
  static const gold =
      Color(0xFFFFC107); // Highlights, pending states, and accent labels
  static const magenta = pink; // Alias for legacy magenta references

  // 3. UI Text Layers
  static const textPrimary = Color(0xFFFFFFFF); // Clean White
  static const textSecondary = Color(0xFF8A8D9F); // Figma cool gray
  static const textMuted = Color(0xFF5C5F73); // Placeholder text

  // 4. Borders & Lines
  static const border = Color(0xFF2C2F42); // Subtle structural lines
  static const borderGlow = Color(0x335DE2E2); // Cyan light leakage

  // 5. The Signature Gradient (Login & Sign Up Buttons)
  static const gradientBrand = LinearGradient(
    colors: [purple, pink],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  static const gradientCyan = LinearGradient(
    colors: [cyan, Color(0xFF37F5F5)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const gradientMagenta = LinearGradient(
    colors: [pink, Color(0xFFFF5AB5)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const gradientGlass = LinearGradient(
    colors: [Color(0x1AFFFFFF), Color(0x05FFFFFF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

// ─── Typography Design Hierarchy ─────────────────────────────────────────────
class AppText {
  static const _base = TextStyle(
    fontFamily: 'Rajdhani',
    color: AppColors.textPrimary,
    letterSpacing: 0.2,
  );

  static TextStyle displayLg = _base.copyWith(
      fontSize: 34, fontWeight: FontWeight.w700, letterSpacing: 0.5);
  static TextStyle displayMd = _base.copyWith(
      fontSize: 28, fontWeight: FontWeight.w700, letterSpacing: 0.3);
  static TextStyle displaySm =
      _base.copyWith(fontSize: 24, fontWeight: FontWeight.w600);
  static TextStyle heading = _base.copyWith(
      fontSize: 19, fontWeight: FontWeight.w600, letterSpacing: 0.5);
  static TextStyle subheading = _base.copyWith(
      fontSize: 16,
      fontWeight: FontWeight.w500,
      color: AppColors.textSecondary);

  static TextStyle body = _base.copyWith(
      fontSize: 14,
      fontWeight: FontWeight.w400,
      color: AppColors.textSecondary,
      fontFamily: 'Inter',
      letterSpacing: 0.1);
  static TextStyle bodyMd = _base.copyWith(
      fontSize: 14,
      fontWeight: FontWeight.w500,
      color: AppColors.textPrimary,
      fontFamily: 'Inter');
  static TextStyle caption = _base.copyWith(
      fontSize: 12,
      fontWeight: FontWeight.w400,
      color: AppColors.textMuted,
      fontFamily: 'Inter');
  static TextStyle label = _base.copyWith(
      fontSize: 11,
      fontWeight: FontWeight.w600,
      letterSpacing: 1.5,
      color: AppColors.textSecondary);

  static TextStyle btnLg = _base.copyWith(
      fontSize: 16, fontWeight: FontWeight.w700, letterSpacing: 2.0);
  static TextStyle btnSm = _base.copyWith(
      fontSize: 13, fontWeight: FontWeight.w600, letterSpacing: 1.2);
}

// ─── App Global Theme Architecture ───────────────────────────────────────────
class AppTheme {
  static ThemeData get dark => ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: AppColors.bg0,
        colorScheme: const ColorScheme.dark(
          primary: AppColors.cyan, // Cyan is your main workhorse color
          secondary: AppColors.pink,
          surface: AppColors.bg1,
          error: AppColors.red,
        ),
        fontFamily: 'Rajdhani',

        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: false,
          iconTheme: IconThemeData(color: AppColors.textPrimary, size: 22),
          systemOverlayStyle: SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: Brightness.light,
            systemNavigationBarColor: AppColors.bg0,
            systemNavigationBarIconBrightness: Brightness.light,
          ),
          titleTextStyle: TextStyle(
            fontFamily: 'Rajdhani',
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
            letterSpacing: 1.0,
          ),
        ),

        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: AppColors.bg1,
          selectedItemColor: AppColors.cyan,
          unselectedItemColor: AppColors.textMuted,
          type: BottomNavigationBarType.fixed,
          elevation: 0,
        ),

        // Inputs matched exactly to Figma (No borders, solid dark fill)
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.bg3,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          prefixIconColor: AppColors.textSecondary,
          suffixIconColor: AppColors.textSecondary,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none, // Clean, borderless look
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(
                color: AppColors.cyan, width: 1.0), // Subtle cyan focus
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.red, width: 1.0),
          ),
          labelStyle: const TextStyle(
              color: AppColors.textSecondary, fontFamily: 'Inter'),
          hintStyle: const TextStyle(
              color: AppColors.textMuted, fontFamily: 'Inter', fontSize: 14),
        ),

        chipTheme: ChipThemeData(
          backgroundColor: AppColors.bg3,
          selectedColor: AppColors.cyan.withOpacity(0.15),
          labelStyle: const TextStyle(
              fontFamily: 'Rajdhani',
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary),
          secondaryLabelStyle: const TextStyle(
              fontFamily: 'Rajdhani',
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.cyan),
          side: const BorderSide(color: AppColors.border),
          checkmarkColor: AppColors.cyan,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),

        dividerTheme: const DividerThemeData(
            color: AppColors.border, space: 1, thickness: 1),
        pageTransitionsTheme: const PageTransitionsTheme(
          builders: {
            TargetPlatform.android: ZoomPageTransitionsBuilder(),
            TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          },
        ),
      );
}

// ─── Obsidian Glass Structural Components ─────────────────────────────────────
class AppDecorations {
  static BoxDecoration glowCard(
          {Color glowColor = AppColors.cyan, double radius = 20}) =>
      BoxDecoration(
        color: AppColors.bg1,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: AppColors.border.withOpacity(0.8)),
        boxShadow: [
          BoxShadow(
            color: glowColor.withOpacity(0.08),
            blurRadius: 32,
            spreadRadius: 1,
            offset: const Offset(0, 16),
          )
        ],
      );

  static BoxDecoration glassCard(
          {double radius = 24, Color? customBorderColor}) =>
      BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0x2B222432), Color(0x1012141D)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(
          color: customBorderColor ?? AppColors.border,
          width: 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            blurRadius: 24,
            offset: const Offset(0, 12),
          )
        ],
      );

  static BoxDecoration accentCard(LinearGradient gradient,
          {double radius = 16}) =>
      BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(radius),
      );

  static BoxDecoration inputDecoration = BoxDecoration(
    color: AppColors.bg3,
    borderRadius: BorderRadius.circular(12),
  );
}
