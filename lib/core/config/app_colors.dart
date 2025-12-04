import 'package:flutter/material.dart';

class AppColors {
  // Backgrounds
  static const Color background = Color(0xFF0B0E14); // Deep Black
  static const Color surface = Color(0xFF1A1A2E); // Dark Purple-ish Grey
  static const Color surfaceLight = Color(0xFF2E2E4A); // Lighter Purple-ish Grey

  // Accents (Evangelion Unit-01 & NERV)
  static const Color primary = Color(0xFF9B59B6); // Unit-01 Purple
  static const Color secondary = Color(0xFF39FF14); // Unit-01 Green
  static const Color accent = Color(0xFFFF9F1C); // NERV Orange
  static const Color danger = Color(0xFFE74C3C); // NERV Red (Alert)

  // Text
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFB0B5C0);
  static const Color textDim = Color(0xFF6B7280);

  // Status
  static const Color success = Color(0xFF39FF14); // Green
  static const Color error = Color(0xFFE74C3C); // Red
  static const Color warning = Color(0xFFFF9F1C); // Orange
  
  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, Color(0xFF8E44AD)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient hudGradient = LinearGradient(
    colors: [Color(0x00FF9F1C), Color(0x33FF9F1C)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}
