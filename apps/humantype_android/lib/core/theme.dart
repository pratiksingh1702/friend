import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class HumanTypeColors {
  static const bgPrimary = Color(0xFF0A0A0F);
  static const bgSecondary = Color(0xFF111118);
  static const bgElevated = Color(0xFF1A1A24);
  static const bgOverlay = Color(0xFF22222E);

  static const borderSubtle = Color(0xFF2A2A3A);
  static const borderDefault = Color(0xFF3A3A4E);
  static const borderStrong = Color(0xFF5A5A7A);

  static const accentPrimary = Color(0xFF6C63FF);
  static const accentSecondary = Color(0xFF4ECDC4);
  static const accentDanger = Color(0xFFFF6B6B);

  static const success = Color(0xFF2ECC71);
  static const warning = Color(0xFFF39C12);
  static const error = Color(0xFFE74C3C);
  static const info = Color(0xFF3498DB);

  static const connExcellent = Color(0xFF2ECC71);
  static const connGood = Color(0xFF27AE60);
  static const connFair = Color(0xFFF39C12);
  static const connPoor = Color(0xFFE67E22);
  static const connBluetooth = Color(0xFF3498DB);
  static const connDisconnected = Color(0xFFE74C3C);
}

class HumanTypeSpacing {
  static const xs = 4.0;
  static const sm = 8.0;
  static const md = 12.0;
  static const lg = 16.0;
  static const xl = 24.0;
  static const xxl = 32.0;
  static const xxxl = 48.0;
}

class HumanTypeAnimation {
  static const quick = Duration(milliseconds: 150);
  static const standard = Duration(milliseconds: 250);
  static const deliberate = Duration(milliseconds: 400);
  static const slow = Duration(milliseconds: 600);

  static const easeOut = Curves.easeOut;
  static const easeInOut = Curves.easeInOut;
}

class HumanTypeText {
  static TextStyle display = GoogleFonts.sora(
    fontSize: 32,
    fontWeight: FontWeight.w700,
    color: Colors.white,
  );
  static TextStyle heading1 = GoogleFonts.sora(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    color: Colors.white,
  );
  static TextStyle heading2 = GoogleFonts.sora(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: Colors.white,
  );
  static TextStyle bodyLarge = GoogleFonts.sora(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: Colors.white,
  );
  static TextStyle body = GoogleFonts.sora(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: Colors.white,
  );
  static TextStyle bodySmall = GoogleFonts.sora(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: Colors.white70,
  );
  static TextStyle caption = GoogleFonts.sora(
    fontSize: 11,
    fontWeight: FontWeight.w500,
    color: Colors.white70,
  );
  static TextStyle monoLarge = GoogleFonts.jetBrainsMono(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: Colors.white,
  );
  static TextStyle mono = GoogleFonts.jetBrainsMono(
    fontSize: 13,
    fontWeight: FontWeight.w400,
    color: Colors.white,
  );
}

ThemeData buildHumanTypeTheme() {
  final colorScheme = const ColorScheme(
    brightness: Brightness.dark,
    primary: HumanTypeColors.accentPrimary,
    onPrimary: Colors.white,
    secondary: HumanTypeColors.accentSecondary,
    onSecondary: Colors.black,
    error: HumanTypeColors.error,
    onError: Colors.white,
    surface: HumanTypeColors.bgSecondary,
    onSurface: Colors.white,
    background: HumanTypeColors.bgPrimary,
    onBackground: Colors.white,
  );

  return ThemeData(
    useMaterial3: true,
    colorScheme: colorScheme,
    scaffoldBackgroundColor: HumanTypeColors.bgPrimary,
    appBarTheme: const AppBarTheme(
      backgroundColor: HumanTypeColors.bgPrimary,
      foregroundColor: Colors.white,
      elevation: 0,
    ),
    cardTheme: CardThemeData(
      color: HumanTypeColors.bgElevated,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: HumanTypeColors.borderSubtle),
      ),
    ),
    dividerColor: HumanTypeColors.borderSubtle,
    textTheme: TextTheme(
      displayLarge: HumanTypeText.display,
      headlineMedium: HumanTypeText.heading1,
      headlineSmall: HumanTypeText.heading2,
      bodyLarge: HumanTypeText.bodyLarge,
      bodyMedium: HumanTypeText.body,
      bodySmall: HumanTypeText.bodySmall,
      labelSmall: HumanTypeText.caption,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: HumanTypeColors.bgElevated,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: HumanTypeColors.borderDefault),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: HumanTypeColors.borderSubtle),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: HumanTypeColors.accentPrimary),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        minimumSize: const Size.fromHeight(48),
        backgroundColor: HumanTypeColors.accentPrimary,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        minimumSize: const Size.fromHeight(48),
        foregroundColor: Colors.white,
        side: const BorderSide(color: HumanTypeColors.borderDefault),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
      ),
    ),
  );
}
