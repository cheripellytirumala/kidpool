import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// Type scale from the kidpool Figma design system
/// (📘 Foundations · Typography · Hanken Grotesk).
///
/// `height` is lineHeight / fontSize; `letterSpacing` is the tracking in
/// logical pixels exactly as Figma resolves it.
class AppTextStyles {
  // Display/XL — 56/54 · Regular
  static TextStyle displayXL = GoogleFonts.hankenGrotesk(
    fontSize: 56,
    height: 54 / 56,
    fontWeight: FontWeight.w400,
    letterSpacing: -1.96,
    color: AppColors.textPrimary,
  );

  // Display/L — 44/44 · Regular
  static TextStyle displayL = GoogleFonts.hankenGrotesk(
    fontSize: 44,
    height: 44 / 44,
    fontWeight: FontWeight.w400,
    letterSpacing: -1.32,
    color: AppColors.textPrimary,
  );

  // Heading/H1 — 32/36 · Medium
  static TextStyle headingH1 = GoogleFonts.hankenGrotesk(
    fontSize: 32,
    height: 36 / 32,
    fontWeight: FontWeight.w500,
    letterSpacing: -0.64,
    color: AppColors.textPrimary,
  );

  // Heading/H2 — 24/28 · SemiBold
  static TextStyle headingH2 = GoogleFonts.hankenGrotesk(
    fontSize: 24,
    height: 28 / 24,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.36,
    color: AppColors.textPrimary,
  );

  // Heading/H3 — 20/24 · SemiBold
  static TextStyle headingH3 = GoogleFonts.hankenGrotesk(
    fontSize: 20,
    height: 24 / 20,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.2,
    color: AppColors.textPrimary,
  );

  // Body/L — 17/24 · Medium
  static TextStyle bodyL = GoogleFonts.hankenGrotesk(
    fontSize: 17,
    height: 24 / 17,
    fontWeight: FontWeight.w500,
    letterSpacing: -0.085,
    color: AppColors.textPrimary,
  );

  // Body/M — 15/22 · Regular
  static TextStyle bodyM = GoogleFonts.hankenGrotesk(
    fontSize: 15,
    height: 22 / 15,
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
    color: AppColors.textPrimary,
  );

  // Body/S — 13/18 · Regular
  static TextStyle bodyS = GoogleFonts.hankenGrotesk(
    fontSize: 13,
    height: 18 / 13,
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
    color: AppColors.textPrimary,
  );

  // Label/L — 16/20 · SemiBold
  static TextStyle labelL = GoogleFonts.hankenGrotesk(
    fontSize: 16,
    height: 20 / 16,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.08,
    color: AppColors.textPrimary,
  );

  // Label/M — 14/18 · SemiBold
  static TextStyle labelM = GoogleFonts.hankenGrotesk(
    fontSize: 14,
    height: 18 / 14,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
    color: AppColors.textPrimary,
  );

  // Label/S — 12/16 · Medium
  static TextStyle labelS = GoogleFonts.hankenGrotesk(
    fontSize: 12,
    height: 16 / 12,
    fontWeight: FontWeight.w500,
    letterSpacing: 0,
    color: AppColors.textPrimary,
  );

  // Number/XL — 40/44 · Bold
  static TextStyle numberXL = GoogleFonts.hankenGrotesk(
    fontSize: 40,
    height: 44 / 40,
    fontWeight: FontWeight.w700,
    letterSpacing: -1,
    color: AppColors.textPrimary,
  );

  // Number/L — 28/32 · Bold
  static TextStyle numberL = GoogleFonts.hankenGrotesk(
    fontSize: 28,
    height: 32 / 28,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.42,
    color: AppColors.textPrimary,
  );
}
