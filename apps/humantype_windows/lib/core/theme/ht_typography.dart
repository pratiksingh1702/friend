import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'ht_colors.dart';

class HTTypography {
  static TextStyle heroHeading = GoogleFonts.inter(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: HTColors.textPrimary,
    letterSpacing: -0.5,
  );

  static TextStyle sectionTitle = GoogleFonts.inter(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: HTColors.textPrimary,
  );

  static TextStyle sidebarLabel = GoogleFonts.inter(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: HTColors.textSecondary,
    letterSpacing: 0.2,
  );

  static TextStyle sidebarCategory = GoogleFonts.inter(
    fontSize: 10,
    fontWeight: FontWeight.bold,
    color: HTColors.textMuted,
    letterSpacing: 1.2,
  );

  static TextStyle cardTitle = GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: HTColors.textPrimary,
  );

  static TextStyle cardSubtitle = GoogleFonts.inter(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: HTColors.textSecondary,
  );

  static TextStyle statusLabel = GoogleFonts.inter(
    fontSize: 10,
    fontWeight: FontWeight.w600,
    color: HTColors.textSecondary,
  );

  static TextStyle readout = GoogleFonts.inter(
    fontSize: 11,
    fontWeight: FontWeight.w500,
    color: HTColors.textPrimary,
  );

  static TextStyle body = GoogleFonts.inter(
    fontSize: 13,
    fontWeight: FontWeight.w400,
    color: HTColors.textSecondary,
  );

  static TextStyle micro = GoogleFonts.inter(
    fontSize: 9,
    fontWeight: FontWeight.w500,
    color: HTColors.textMuted,
  );
}
