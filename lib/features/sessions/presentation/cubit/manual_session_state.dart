import 'package:equatable/equatable.dart';

import '../../../../core/error/failure.dart';
import '../../domain/entities/unlocked_badge.dart';

sealed class ManualSessionState extends Equatable {
  const ManualSessionState();

  @override
  List<Object?> get props => [];
}

class ManualSessionIdle extends ManualSessionState {
  const ManualSessionIdle();
}

class ManualSessionSubmitting extends ManualSessionState {
  const ManualSessionSubmitting();
}

/// The session is saved locally and the form can close. [badgesUnlocked] may
/// arrive late (the remote send is best-effort), so it can be empty here and
/// filled in by a later emission.
class ManualSessionSubmitted extends ManualSessionState {
  const ManualSessionSubmitted({required this.badgesUnlocked});

  final List<UnlockedBadge> badgesUnlocked;

  @override
  List<Object?> get props => [badgesUnlocked];
}

class ManualSessionError extends ManualSessionState {
  const ManualSessionError(this.failure);

  final Failure failure;

  @override
  List<Object?> get props => [failure];
}
