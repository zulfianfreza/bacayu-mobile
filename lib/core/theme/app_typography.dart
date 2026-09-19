import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

/// Type scale from BacaYu Style Guide Section 3. Font is Nunito, weights
/// 400/600/700/800 only — do not introduce other weights or families here.
class AppTypography {
  AppTypography._();

  static TextStyle _nunito({
    required double fontSize,
    required FontWeight fontWeight,
    required double height,
    Color color = AppColors.ink,
  }) {
    return GoogleFonts.nunito(
      fontSize: fontSize,
      fontWeight: fontWeight,
      height: height,
      color: color,
    );
  }

  /// 40px ExtraBold — streak count, other large dashboard numbers.
  static TextStyle get displayLg => _nunito(
        fontSize: 40,
        fontWeight: FontWeight.w800,
        height: 1.15,
      );

  /// 28px ExtraBold — main page titles.
  static TextStyle get displaySm => _nunito(
        fontSize: 28,
        fontWeight: FontWeight.w800,
        height: 1.2,
      );

  /// 20px Bold — section/card titles.
  static TextStyle get heading => _nunito(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        height: 1.3,
      );

  /// 16px Bold — book titles, badge names.
  static TextStyle get subheading => _nunito(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        height: 1.4,
      );

  /// 15px Regular — description paragraphs.
  static TextStyle get body => _nunito(
        fontSize: 15,
        fontWeight: FontWeight.w400,
        height: 1.6,
      );

  /// 15px SemiBold — important labels, small statistic numbers.
  static TextStyle get bodyStrong => _nunito(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        height: 1.5,
      );

  /// 13px Medium — metadata, timestamps, helper text.
  static TextStyle get caption => _nunito(
        fontSize: 13,
        fontWeight: FontWeight.w500,
        height: 1.4,
        color: AppColors.slate600,
      );

  /// 15px SemiBold — button and nav labels.
  static TextStyle get button => _nunito(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        height: 1,
      );
}
