import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Wellet Connect design tokens.
///
/// This is the FLIPPED identity per
/// `wellet-connect-design-spec`: where the parent Wellet app is moss-on-cream
/// (caregiver, observational), Connect is cream-on-moss (care recipient,
/// agentic, owned).
///
/// Color tokens come from `wellet-design-library` and are SHARED between the
/// two apps — only the role assignments flip.
class WelletTheme {
  // ---------------------------------------------------------------------------
  // Brand palette — shared with Wellet (do not introduce new hex values).
  // ---------------------------------------------------------------------------

  /// Moss — Connect's app surface. On Wellet this is the accent color.
  static const Color moss = Color(0xFF608F7C);
  static const Color mossDark = Color(0xFF4F7A68);
  static const Color mint = Color(0xFFDCE9E2);
  static const Color mintDeep = Color(0xFFC5D9CE);

  /// Cream — Connect's accent / type color on moss surfaces.
  static const Color cream = Color(0xFFF7F5F0);
  static const Color warmWhite = Color(0xFFFDFCFA);

  // Inside-card type tokens (cream-led / inside warm-white surfaces)
  static const Color textPrimary = Color(0xFF2C2A26);
  static const Color textSecondary = Color(0xFF6B6560);
  static const Color textMuted = Color(0xFF9E9A94);

  // Semantic tokens (unchanged across both apps)
  static const Color amber = Color(0xFFC97B2C);
  static const Color amberBg = Color(0xFFFDF5E8);
  static const Color red = Color(0xFFC0392B);
  static const Color blue = Color(0xFF3B6EA5);
  static const Color green = Color(0xFF47B08A);
  static const Color greenBg = Color(0xFFEDF7F2);

  // ---------------------------------------------------------------------------
  // Connect role aliases — use these inside the app.
  // ---------------------------------------------------------------------------

  /// App background for Connect (moss-led).
  static const Color background = moss;

  /// Working surface (cards on moss).
  static const Color surface = warmWhite;

  /// Primary CTA fill on moss surfaces (filled cream button).
  static const Color primary = warmWhite;
  static const Color primaryText = mossDark;
  static const Color primaryPressed = mint;

  /// Border for warm-white cards floating on moss.
  static const Color cardBorderOnMoss = Color(0x2EFFFFFF); // rgba(255,255,255,0.18)
  /// Border for warm-white cards on cream (Wellet pattern, used on cream-led screens).
  static const Color cardBorderOnCream = Color(0x1F4F4D5C); // rgba(79,77,92,0.12)

  /// Body text aliases for type ON moss.
  static const Color onMossHeading = cream;
  static const Color onMossBody = warmWhite; // use opacity 0.85 at site
  static const Color onMossLabel = mint; // use opacity 0.9 at site

  // Legacy aliases (kept so existing screens that reference these don't break
  // mid-migration). They now point at semantically-correct Connect tokens.
  static const Color primaryHover = mossDark;
  static const Color primaryDark = mossDark;
  static const Color primaryLight = mint;
  static const Color accent = mossDark;
  static const Color accentLight = mint;
  static const Color surfaceOffset = mint;
  static const Color divider = Color(0x33FFFFFF); // hairline on moss
  static const Color border = cardBorderOnMoss;
  static const Color textFaint = textMuted;
  static const Color error = red;
  static const Color success = green;
  static const Color surfaceLight = warmWhite;

  static const double minFontSize = 20.0;
  static const double minTouchTarget = 56.0;

  static ThemeData get lightTheme {
    // Connect default surface = MOSS. Type and CTAs are styled to read on moss.
    // Cream-led screens override these locally.
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: moss,
        primary: warmWhite, // primary CTA is cream
        onPrimary: mossDark, // text on the cream CTA
        secondary: cream,
        onSecondary: mossDark,
        surface: warmWhite,
        onSurface: textPrimary,
        error: red,
        brightness: Brightness.light,
      ),
      scaffoldBackgroundColor: moss,
      textTheme: _textTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: moss,
        foregroundColor: cream,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.dmSerifDisplay(
          fontSize: 24,
          fontWeight: FontWeight.w400,
          color: cream,
        ),
      ),
      // Primary CTA on moss = warm-white fill, moss-dark text.
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.disabled)) {
              return warmWhite.withOpacity(0.5);
            }
            if (states.contains(WidgetState.pressed)) return mint;
            return warmWhite;
          }),
          foregroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.disabled)) {
              return mossDark.withOpacity(0.6);
            }
            return mossDark;
          }),
          minimumSize: WidgetStateProperty.all(
            const Size(double.infinity, minTouchTarget),
          ),
          textStyle: WidgetStateProperty.all(
            GoogleFonts.dmSans(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          shape: WidgetStateProperty.all(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          elevation: WidgetStateProperty.all(0),
          shadowColor: WidgetStateProperty.all(Colors.transparent),
        ),
      ),
      // Secondary CTA on moss = 1.5px cream border, transparent fill, cream text.
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: ButtonStyle(
          foregroundColor: WidgetStateProperty.all(cream),
          backgroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.pressed)) {
              return cream.withOpacity(0.12);
            }
            return Colors.transparent;
          }),
          minimumSize: WidgetStateProperty.all(
            const Size(double.infinity, minTouchTarget),
          ),
          textStyle: WidgetStateProperty.all(
            GoogleFonts.dmSans(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          side: WidgetStateProperty.all(
            const BorderSide(color: cream, width: 1.5),
          ),
          shape: WidgetStateProperty.all(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: warmWhite,
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: mossDark, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: red, width: 1.5),
        ),
        labelStyle: GoogleFonts.dmSans(fontSize: 16, color: textMuted),
        hintStyle: GoogleFonts.dmSans(fontSize: 16, color: textMuted),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: warmWhite,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: const BorderSide(color: cardBorderOnMoss, width: 1),
        ),
        margin: const EdgeInsets.symmetric(vertical: 8),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: moss,
        selectedItemColor: cream,
        unselectedItemColor: mint,
        selectedLabelStyle: GoogleFonts.dmSans(
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
        unselectedLabelStyle: GoogleFonts.dmSans(fontSize: 12),
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
    );
  }

  // Default text theme assumes type lives on moss surfaces.
  // Inside warm-white cards, override locally to textPrimary/textSecondary.
  static TextTheme get _textTheme {
    return TextTheme(
      displayLarge: GoogleFonts.dmSerifDisplay(
        fontSize: 36,
        fontWeight: FontWeight.w400,
        color: cream,
        height: 1.18,
      ),
      displayMedium: GoogleFonts.dmSerifDisplay(
        fontSize: 32,
        fontWeight: FontWeight.w400,
        color: cream,
        height: 1.18,
      ),
      headlineLarge: GoogleFonts.dmSerifDisplay(
        fontSize: 28,
        fontWeight: FontWeight.w400,
        color: cream,
      ),
      headlineMedium: GoogleFonts.dmSerifDisplay(
        fontSize: 24,
        fontWeight: FontWeight.w400,
        color: cream,
      ),
      titleLarge: GoogleFonts.dmSans(
        fontSize: 18,
        fontWeight: FontWeight.w500,
        color: cream,
      ),
      titleMedium: GoogleFonts.dmSans(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: cream,
      ),
      bodyLarge: GoogleFonts.dmSans(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: warmWhite,
      ),
      bodyMedium: GoogleFonts.dmSans(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: warmWhite,
      ),
      labelLarge: GoogleFonts.dmSans(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: cream,
      ),
    );
  }
}

/// Surface mode for any Connect screen. Used by widgets to resolve the right
/// type and icon colors.
enum ConnectSurface { moss, cream }
