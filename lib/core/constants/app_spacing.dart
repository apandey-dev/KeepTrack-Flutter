import 'package:flutter/material.dart';

/// AppSpacing provides consistent 8-point spacing system and border radius constants.
class AppSpacing {
  AppSpacing._();

  // Spacing
  static const double xxs = 4.0;
  static const double xs = 8.0;
  static const double sm = 12.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
  static const double xxl = 40.0;
  static const double xxxl = 48.0;

  // EdgeInsets shortcuts
  static const EdgeInsets pagePadding = EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0);
  static const EdgeInsets cardPadding = EdgeInsets.all(16.0);
  static const EdgeInsets sheetPadding = EdgeInsets.fromLTRB(20.0, 16.0, 20.0, 24.0);

  // Border Radii
  static const double radiusXs = 6.0;
  static const double radiusSm = 10.0;
  static const double radiusMd = 16.0;
  static const double radiusLg = 22.0;
  static const double radiusPill = 999.0;

  static final BorderRadius roundedMd = BorderRadius.circular(radiusMd);
  static final BorderRadius roundedLg = BorderRadius.circular(radiusLg);
  static final BorderRadius roundedPill = BorderRadius.circular(radiusPill);
}
