import 'package:equatable/equatable.dart';

/// Mirrors `UnlockedBadgeResponse` in
/// `api/internal/features/sessions/delivery/http/response.go` — the
/// `badges` feature isn't built yet, so this stays scoped to what the
/// session submit fast-path (CLAUDE.md backend Section 8.4) needs to render
/// a celebratory banner. Not the eventual full `Badge` entity.
class UnlockedBadge extends Equatable {
  const UnlockedBadge({
    required this.badgeId,
    required this.name,
    required this.icon,
    required this.description,
  });

  final String badgeId;
  final String name;
  final String icon;
  final String description;

  @override
  List<Object?> get props => [badgeId, name, icon, description];
}
