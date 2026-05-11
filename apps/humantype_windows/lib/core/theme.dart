import 'package:fluent_ui/fluent_ui.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color primaryColor = Color(0xFF0078D4); // Fluent Blue
  static const Color backgroundColor = Color(0xFFF3F3F3);
  static const Color surfaceColor = Colors.white;

  static FluentThemeData get light {
    return FluentThemeData(
      brightness: Brightness.light,
      accentColor: AccentColor.swatch({
        'darkest': const Color(0xff004578),
        'darker': const Color(0xff005a9e),
        'dark': const Color(0xff0078d4),
        'normal': primaryColor,
        'light': const Color(0xff2b88d8),
        'lighter': const Color(0xffc7e0f4),
        'lightest': const Color(0xffeff6fc),
      }),
      visualDensity: VisualDensity.standard,
      typography: Typography.raw(
        body: GoogleFonts.inter(fontSize: 14, color: Colors.black),
        bodyStrong: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black),
        bodyLarge: GoogleFonts.inter(fontSize: 16, color: Colors.black),
        subtitle: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w600, color: Colors.black),
        title: GoogleFonts.inter(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.black),
        titleLarge: GoogleFonts.inter(fontSize: 40, fontWeight: FontWeight.bold, color: Colors.black),
        caption: GoogleFonts.inter(fontSize: 12, color: Colors.grey[100]),
      ),
    );
  }

  static FluentThemeData get dark {
    return FluentThemeData(
      brightness: Brightness.dark,
      accentColor: AccentColor.swatch({
        'darkest': const Color(0xff004578),
        'darker': const Color(0xff005a9e),
        'dark': const Color(0xff0078d4),
        'normal': primaryColor,
        'light': const Color(0xff2b88d8),
        'lighter': const Color(0xffc7e0f4),
        'lightest': const Color(0xffeff6fc),
      }),
      visualDensity: VisualDensity.standard,
      scaffoldBackgroundColor: const Color(0xFF202020),
      typography: Typography.raw(
        body: GoogleFonts.inter(fontSize: 14, color: Colors.white),
        bodyStrong: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
        bodyLarge: GoogleFonts.inter(fontSize: 16, color: Colors.white),
        subtitle: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w600, color: Colors.white),
        title: GoogleFonts.inter(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
        titleLarge: GoogleFonts.inter(fontSize: 40, fontWeight: FontWeight.bold, color: Colors.white),
        caption: GoogleFonts.inter(fontSize: 12, color: Colors.grey[60]),
      ),
    );
  }
}
