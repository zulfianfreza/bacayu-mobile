import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_typography.dart';

/// A labelled field in the app's auth surfaces.
///
/// The label sits above the box rather than floating inside it — it then reads
/// as a label at rest instead of only once the field is focused. The box is the
/// chunky one the rest of the app's controls use: a thick rounded border, with
/// focus (and error) called out by colour rather than by a hairline.
class AuthTextField extends StatelessWidget {
  const AuthTextField({
    super.key,
    required this.label,
    required this.controller,
    this.validator,
    this.keyboardType,
    this.obscureText = false,
    this.icon,
    this.textInputAction,
  });

  final String label;
  final TextEditingController controller;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final bool obscureText;

  /// Placeholder glyph on the right of the field.
  final IconData? icon;

  final TextInputAction? textInputAction;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTypography.caption.copyWith(
            color: AppColors.ink,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          validator: validator,
          keyboardType: keyboardType,
          obscureText: obscureText,
          textInputAction: textInputAction,
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
            prefixIcon: icon == null
                ? null
                : Icon(icon, size: 20, color: AppColors.inkFaint),
            border: _border(AppColors.line),
            enabledBorder: _border(AppColors.line),
            focusedBorder: _border(AppColors.tangerine, width: 2.5),
            errorBorder: _border(AppColors.danger),
            focusedErrorBorder: _border(AppColors.danger, width: 2.5),
          ),
        ),
      ],
    );
  }

  OutlineInputBorder _border(Color color, {double width = 2}) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppRadius.md),
      borderSide: BorderSide(color: color, width: width),
    );
  }
}
