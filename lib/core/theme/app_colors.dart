import 'package:flutter/material.dart';

/// Color tokens from BacaYu Style Guide Section 2. Values must stay in sync
/// with `docs/BacaYu_Style_Guide.md` — do not hand-tune hex values here.
///
/// Three groups live in this file:
///
/// * the **brand** palette (§2.1–2.3) — the app's own warm colors, each with
///   a full 50–900 ramp;
/// * **semantic roles** — what a state *is*, mapped onto those families so a
///   "success" chip can never be a different green from the rest of the app;
/// * an **extended** palette — Tailwind v3's hexes, for the hues the brand
///   does not own. Those are borrowed values, not brand decisions: reach for
///   them for one-off accents, charts, and states, not for chrome.
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
  static const tangerine200 = Color(0xFFFFC2A3);
  static const tangerine300 = Color(0xFFFFA477);
  static const tangerine400 = Color(0xFFFF895A);
  static const tangerine500 = Color(0xFFFF6A3D);
  static const tangerine600 = Color(0xFFEE592E);
  static const tangerine700 = Color(0xFFD94A22);
  static const tangerine800 = Color(0xFF9C4830);
  static const tangerine900 = Color(0xFF8C2E12);

  // Lagoon ramp (Style Guide 2.2)
  static const lagoon50 = Color(0xFFE6FBF8);
  static const lagoon100 = Color(0xFFB8F0E8);
  static const lagoon200 = Color(0xFF8BE5D9);
  static const lagoon300 = Color(0xFF5FD9CB);
  static const lagoon400 = Color(0xFF38CAB8);
  static const lagoon500 = Color(0xFF14B8A6);
  static const lagoon600 = Color(0xFF327E75);
  static const lagoon700 = Color(0xFF0E8577);
  static const lagoon800 = Color(0xFF2E4E4A);
  static const lagoon900 = Color(0xFF0A5A50);

  // Sunshine ramp (Style Guide 2.2)
  static const sunshine50 = Color(0xFFFFF8E1);
  static const sunshine100 = Color(0xFFFFEDB3);
  static const sunshine200 = Color(0xFFFFE596);
  static const sunshine300 = Color(0xFFFFDD7A);
  static const sunshine400 = Color(0xFFFCD25E);
  static const sunshine500 = Color(0xFFFFC93C);
  static const sunshine600 = Color(0xFFEAB630);
  static const sunshine700 = Color(0xFFD9A420);
  static const sunshine800 = Color(0xFF9A7C2F);
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

  // Neutral surfaces. The warm-tinted grays this used to carry (ink soft/ink
  // faint/line) are gone: every secondary text, divider and hairline in the app
  // is drawn from the slate ramp instead — slate400, slate600, slate200
  // respectively, matched on darkness.
  static const surface = Color(0xFFFFFFFF);

  // Semantic roles (Style Guide 2.5) — the state, not the hue. Each points at
  // a family above: success and danger wear the brand's own positive and
  // negative colors, and warning deliberately avoids Sunshine (the guide
  // reserves that for achievements, not for "something needs attention").
  static const success = lagoon500;
  static const danger = berry;
  static const warning = amber500;
  static const info = blue500;

  // Extended palette — Tailwind v3. The hues the brand does not own, so a
  // chart series or a one-off state never has to be invented on the spot.
  // Full 50–900 per family, same shape as the brand ramps.

  static const red50 = Color(0xFFFEF2F2);
  static const red100 = Color(0xFFFEE2E2);
  static const red200 = Color(0xFFFECACA);
  static const red300 = Color(0xFFFCA5A5);
  static const red400 = Color(0xFFF87171);
  static const red500 = Color(0xFFEF4444);
  static const red600 = Color(0xFFDC2626);
  static const red700 = Color(0xFFB91C1C);
  static const red800 = Color(0xFF991B1B);
  static const red900 = Color(0xFF7F1D1D);

  static const amber50 = Color(0xFFFFFBEB);
  static const amber100 = Color(0xFFFEF3C7);
  static const amber200 = Color(0xFFFDE68A);
  static const amber300 = Color(0xFFFCD34D);
  static const amber400 = Color(0xFFFBBF24);
  static const amber500 = Color(0xFFF59E0B);
  static const amber600 = Color(0xFFD97706);
  static const amber700 = Color(0xFFB45309);
  static const amber800 = Color(0xFF92400E);
  static const amber900 = Color(0xFF78350F);

  static const green50 = Color(0xFFF0FDF4);
  static const green100 = Color(0xFFDCFCE7);
  static const green200 = Color(0xFFBBF7D0);
  static const green300 = Color(0xFF86EFAC);
  static const green400 = Color(0xFF4ADE80);
  static const green500 = Color(0xFF22C55E);
  static const green600 = Color(0xFF16A34A);
  static const green700 = Color(0xFF15803D);
  static const green800 = Color(0xFF166534);
  static const green900 = Color(0xFF14532D);

  static const blue50 = Color(0xFFEFF6FF);
  static const blue100 = Color(0xFFDBEAFE);
  static const blue200 = Color(0xFFBFDBFE);
  static const blue300 = Color(0xFF93C5FD);
  static const blue400 = Color(0xFF60A5FA);
  static const blue500 = Color(0xFF3B82F6);
  static const blue600 = Color(0xFF2563EB);
  static const blue700 = Color(0xFF1D4ED8);
  static const blue800 = Color(0xFF1E40AF);
  static const blue900 = Color(0xFF1E3A8A);

  static const indigo50 = Color(0xFFEEF2FF);
  static const indigo100 = Color(0xFFE0E7FF);
  static const indigo200 = Color(0xFFC7D2FE);
  static const indigo300 = Color(0xFFA5B4FC);
  static const indigo400 = Color(0xFF818CF8);
  static const indigo500 = Color(0xFF6366F1);
  static const indigo600 = Color(0xFF4F46E5);
  static const indigo700 = Color(0xFF4338CA);
  static const indigo800 = Color(0xFF3730A3);
  static const indigo900 = Color(0xFF312E81);

  static const violet50 = Color(0xFFF5F3FF);
  static const violet100 = Color(0xFFEDE9FE);
  static const violet200 = Color(0xFFDDD6FE);
  static const violet300 = Color(0xFFC4B5FD);
  static const violet400 = Color(0xFFA78BFA);
  static const violet500 = Color(0xFF8B5CF6);
  static const violet600 = Color(0xFF7C3AED);
  static const violet700 = Color(0xFF6D28D9);
  static const violet800 = Color(0xFF5B21B6);
  static const violet900 = Color(0xFF4C1D95);

  static const purple50 = Color(0xFFFAF5FF);
  static const purple100 = Color(0xFFF3E8FF);
  static const purple200 = Color(0xFFE9D5FF);
  static const purple300 = Color(0xFFD8B4FE);
  static const purple400 = Color(0xFFC084FC);
  static const purple500 = Color(0xFFA855F7);
  static const purple600 = Color(0xFF9333EA);
  static const purple700 = Color(0xFF7E22CE);
  static const purple800 = Color(0xFF6B21A8);
  static const purple900 = Color(0xFF581C87);

  static const pink50 = Color(0xFFFDF2F8);
  static const pink100 = Color(0xFFFCE7F3);
  static const pink200 = Color(0xFFFBCFE8);
  static const pink300 = Color(0xFFF9A8D4);
  static const pink400 = Color(0xFFF472B6);
  static const pink500 = Color(0xFFEC4899);
  static const pink600 = Color(0xFFDB2777);
  static const pink700 = Color(0xFFBE185D);
  static const pink800 = Color(0xFF9D174D);
  static const pink900 = Color(0xFF831843);

  static const cyan50 = Color(0xFFECFEFF);
  static const cyan100 = Color(0xFFCFFAFE);
  static const cyan200 = Color(0xFFA5F3FC);
  static const cyan300 = Color(0xFF67E8F9);
  static const cyan400 = Color(0xFF22D3EE);
  static const cyan500 = Color(0xFF06B6D4);
  static const cyan600 = Color(0xFF0891B2);
  static const cyan700 = Color(0xFF0E7490);
  static const cyan800 = Color(0xFF155E75);
  static const cyan900 = Color(0xFF164E63);
}
