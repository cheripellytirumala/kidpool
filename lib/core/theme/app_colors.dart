import 'package:flutter/material.dart';

/// Colour tokens from the kidpool Figma design system
/// (CarPooling_For_Student · 🎨 Design System · 📘 Foundations · Color).
class AppColors {
  // Brand Colors
  static const Color lime = Color(0xFFC7FF2E);
  static const Color limeSoft = Color(0xFFEEFFC4);
  static const Color ink = Color(0xFF0F0F0F);
  static const Color charcoal = Color(0xFF2E2E2E);

  // Background Colors
  static const Color bgScreen = Color(0xFFFFFFFF);
  static const Color bgSurface = Color(0xFFF2F2F2);
  static const Color bgSurfaceStrong = Color(0xFFE6E6E6);
  static const Color bgInverse = Color(0xFF0F0F0F);
  static const Color bgInverseRaised = Color(0xFF1C1C1C);

  // Text & Status Colors
  static const Color textSecondary = Color(0xFF808080);
  static const Color textOnDarkMuted = Color(0xFF9A9A9A);
  static const Color statusSos = Color(0xFFFF4D3D);
  static const Color statusWarning = Color(0xFFFFB020);
  static const Color statusInfo = Color(0xFF5B8CFF);

  // Semantic text roles used by the Figma components
  // (text/primary, text/on-dark, text/on-lime, text/accent).
  static const Color textPrimary = ink;
  static const Color textOnDark = Color(0xFFFFFFFF);
  static const Color textOnLime = ink;
  static const Color textAccent = lime;

  // Border used by the Outline button (1.5px, brand/ink).
  static const Color borderStrong = ink;

  // border/subtle — note cards and dividers on light surfaces.
  static const Color borderSubtle = Color(0xFFE6E6E6);

  // border/dark — dividers on bg/inverse surfaces.
  static const Color borderDark = charcoal;
}
