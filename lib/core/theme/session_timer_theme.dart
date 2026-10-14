import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_typography.dart';

abstract final class SessionTimerTheme {
  static const background = AppColors.tangerine500;
  static const white = Colors.white;
  static const gradient = [background, Color(0xFFF65F35)];
  static const layers = [
    Color(0xFFFF926F),
    Color(0xFFFF8158),
    Color(0xFFF66B40),
    Color(0xFFE95A30),
  ];
  static const pulse = Duration(seconds: 4);
  static const fade = Duration(milliseconds: 250);
  static const padding = 24.0;
  static const gap = 16.0;
  static const maxWidth = 440.0;
  static const circleSize = 360.0;
  static const pauseSize = 80.0;
  static const iconSize = 32.0;
  static const touchSize = 48.0;
  static const shadow = BoxShadow(
    color: Color(0x18000000),
    blurRadius: 20,
    offset: Offset(0, 6),
  );
  static TextStyle get status => AppTypography.displaySm.copyWith(
    fontSize: 32,
    color: white,
    fontWeight: FontWeight.w700,
  );
  static TextStyle get timer => AppTypography.displayLg.copyWith(
    color: white,
    fontWeight: FontWeight.w600,
    fontFeatures: const [FontFeature.tabularFigures()],
  );
}
