import 'package:flutter/material.dart';

/// Color tokens from BacaYu Style Guide Section 2. Values must stay in sync
/// with `docs/BacaYu_Style_Guide.md` — do not hand-tune hex values here.
class AppColors {
  AppColors._();

  // Named colors (Style Guide 2.1)
  static const tangerine = Color(0xFFFF6A3D);
  static const background = Color(0xFFFFFFFF);
  static const ink = Color(0xFF2B2117);
  static const lagoon = Color(0xFF14B8A6);
  static const sunshine = Color(0xFFFFC93C);
  static const berry = Color(0xFFFF4D6D);
  static const slate = Color(0xFF64748B);

  // Tangerine ramp (Style Guide 2.2)
  static const tangerine50 = Color(0xFFFFF1EB);
  static const tangerine100 = Color(0xFFFFE0D1);
  static const tangerine300 = Color(0xFFFFA477);
  static const tangerine500 = Color(0xFFFF6A3D);
  static const tangerine700 = Color(0xFFD94A22);
  static const tangerine900 = Color(0xFF8C2E12);

  // Lagoon ramp (Style Guide 2.2)
  static const lagoon50 = Color(0xFFE6FBF8);
  static const lagoon100 = Color(0xFFB8F0E8);
  static const lagoon300 = Color(0xFF5FD9CB);
  static const lagoon500 = Color(0xFF14B8A6);
  static const lagoon700 = Color(0xFF0E8577);
  static const lagoon900 = Color(0xFF0A5A50);

  // Sunshine ramp (Style Guide 2.2)
  static const sunshine50 = Color(0xFFFFF8E1);
  static const sunshine100 = Color(0xFFFFEDB3);
  static const sunshine300 = Color(0xFFFFDD7A);
  static const sunshine500 = Color(0xFFFFC93C);
  static const sunshine700 = Color(0xFFD9A420);
  static const sunshine900 = Color(0xFF8C6A0E);

  // Slate ramp
  static const slate50 = Color(0xFFF8FAFC);
  static const slate100 = Color(0xFFF1F5F9);
  static const slate200 = Color(0xFFE2E8F0);
  static const slate300 = Color(0xFFCBD5E1);
  static const slate400 = Color(0xFF94A3B8);
  static const slate500 = Color(0xFF64748B);
  static const slate600 = Color(0xFF475569);
  static const slate700 = Color(0xFF334155);
  static const slate800 = Color(0xFF1E293B);
  static const slate900 = Color(0xFF0F172A);

  // Neutral / grayscale, warm-tinted (Style Guide 2.3)
  static const inkSoft = Color(0xFF6B5D50);
  static const inkFaint = Color(0xFFA79C8F);
  static const line = Color(0xFFEFE4D8);
  static const surface = Color(0xFFFFFFFF);
}
