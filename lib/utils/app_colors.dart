import 'package:flutter/material.dart';

/// Colors used across the app, matching the design mockup.
class AppColors {
  // Main green used for buttons, icons, and highlights.
  static const Color primaryGreen = Color(0xFF2E7D5B);

  // Light green background, used behind icons/badges.
  static const Color lightGreen = Color(0xFFE3F2E9);

  // Light grey fill used behind text fields.
  static const Color fieldFill = Color(0xFFF2F2F4);

  // Shared background for the top app bar and bottom nav bar, so both
  // "bars" read as one consistent piece of chrome around the white content.
  static const Color barBackground = Color(0xFFF2F2F4);

  // Grey used for subtitles and helper text.
  static const Color textGrey = Color(0xFF8A8D93);

  // Warm red/orange used for "reset" or destructive actions.
  static const Color warningRed = Color(0xFFE8695A);
}
