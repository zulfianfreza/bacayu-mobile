import 'package:equatable/equatable.dart';

/// Mirrors `BadgeResponse` in
/// `api/internal/features/badges/delivery/http/response.go` (the subset
/// the app actually displays — `slug`/`category`/`is_hidden` aren't needed
/// client-side, the hidden-badge masking already happens server-side).
///
/// Named `Badge` per CLAUDE.md — collides with `package:flutter/material.dart`'s
/// notification-dot `Badge` widget, so any file importing both must
/// `hide Badge` on the material import.
class Badge extends Equatable {
  const Badge({
    required this.id,
    required this.name,
    required this.icon,
    required this.description,
    required this.imageUrl,
    required this.unlocked,
    required this.unlockedAt,
  });

  final String id;
  final String name;
  final String icon;
  final String description;
  final String? imageUrl;
  final bool unlocked;
  final DateTime? unlockedAt;

  @override
  List<Object?> get props => [
        id,
        name,
        icon,
        description,
        imageUrl,
        unlocked,
        unlockedAt,
      ];
}
