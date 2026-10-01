// Manages application-wide constants, color schemes, and asset paths for ShareLoop
import 'package:flutter/material.dart';

class AppColors {
  // Brand Colors (Stitch Palette)
  static const Color brandPrimary = Color(0xFF69B329);     // #69b329 - Stitch Brand 500
  static const Color brandPrimaryDark = Color(0xFF589B21); // #589b21 - Stitch Brand 600
  static const Color brandDark = Color(0xFF467C19);        // #467c19 - Stitch Brand 700
  static const Color brandDarker = Color(0xFF345E12);      // #345e12 - Stitch Brand 800
  static const Color brandDarkest = Color(0xFF233F0A);     // #233f0a - Stitch Brand 900
  static const Color brand50 = Color(0xFFF2F8EB);          // #f2f8eb - Stitch Brand 50
  static const Color brand100 = Color(0xFFE1F0D3);         // #e1f0d3 - Stitch Brand 100
  static const Color brand200 = Color(0xFFC3E1A7);

  // Background & Surface Colors (Stitch Canvas)
  static const Color background = Color(0xFFF7FAF5);       // #f7faf5 - Stitch surface default
  static const Color surfaceBg = Color(0xFFFFFFFF);        // Pure White Cards & Panels
  static const Color surfaceDim = Color(0xFFE8EDE4);       // #e8ede4 - Stitch surface dim
  static const Color surfaceSecondaryBg = Color(0xFFF1F8F2);
  static const Color brandTertiary = Color(0xFFFFFFFF);

  // Dark presentation toolbar & frames
  static const Color darkBg = Color(0xFF0F140C);
  static const Color darkCard = Color(0xFF1A2315);
  static const Color darkBorder = Color(0xFF2D3E23);
  static const Color darkSelect = Color(0xFF24331C);
  
  // Input & Interactive Fills
  static const Color inputBg = Color(0xFFFFFFFF);
  static const Color surfaceHover = Color(0xFFF0F4F0);

  // Text Colors (High Contrast & Stitch Slate Palette)
  static const Color textPrimary = Color(0xFF0F172A);     // Slate 900 Charcoal
  static const Color textSecondary = Color(0xFF475569);   // Slate 600 Muted Metadata
  static const Color textTertiary = Color(0xFF94A3B8);    // Slate 400 Placeholder
  static const Color onBrand = Color(0xFFFFFFFF);         // White text on primary fill

  // Border & Divider Colors
  static const Color borderPrimary = Color(0xFFE2E8F0);   // Slate 200 Divider
  static const Color borderSecondary = Color(0xFFCBD5E1); // Slate 300
  static const Color borderSelected = Color(0xFF69B329);  // Active input / selection border

  // Status & Accent Colors
  static const Color colorError = Color(0xFFE11D48);      // Rose 600
  static const Color colorErrorBg = Color(0xFFFFF1F2);    // Rose 50
  static const Color accentAmber = Color(0xFFF59E0B);     // Amber 500
  static const Color accentAmberBg = Color(0xFFFFFBEB);   // Amber 50
  static const Color accentEmerald = Color(0xFF059669);   // Emerald 600
  static const Color accentRose = Color(0xFFE11D48);
  static const Color colorWarningBorder = Color(0xFFF59E0B);
  static const Color colorWarningBg = Color(0xFFFEF3C7);
  static const Color colorWarningText = Color(0xFF92400E);
  static const Color awardGold = Color(0xFFF59E0B);
  static const Color accentFresh = Color(0xFF69B329);
  static const Color secondary = Color(0xFF589B21);
  static const Color tertiary = Color(0xFFE1F0D3);
  static const Color colorAction = Color(0xFF69B329);
}

// Manages asset paths for images and logos used across the application
class AppImages {
  static const String logo = 'assets/images/shareloop_logo.png';
  static const String logoAlt = 'assets/images/logo.png';
  static const String onboarding1 = 'assets/images/screen1.png';
  static const String onboarding2 = 'assets/images/screen2.png';
  static const String onboarding3 = 'assets/images/screen3.png';
}

class AppStrings {
  static const String appName = 'ShareLoop';
  static const String appTagline = 'Eco-Circular Community';
  static const String appDescription = 'Give unused items a second life with your neighborhood.';
  static const String sinhalaTagline = 'දෙන්න • භාවිත කරන්න • වෙනස ගොඩනගන්න';
  static const String tamilTagline = 'கொடுங்கள் • பயன்படுத்துங்கள் • மாற்றத்தை உருவாக்குங்கள்';
}