import 'package:equatable/equatable.dart';

import '../../../../core/error/failure.dart';
import '../../domain/entities/badge.dart';

sealed class BadgeState extends Equatable {
  const BadgeState();

  @override
  List<Object?> get props => [];
}

class BadgeInitial extends BadgeState {
  const BadgeInitial();
}

class BadgeLoading extends BadgeState {
  const BadgeLoading();
}

class BadgeLoaded extends BadgeState {
  const BadgeLoaded(this.badges);

  final List<Badge> badges;

  @override
  List<Object?> get props => [badges];
}

class BadgeError extends BadgeState {
  const BadgeError(this.failure);

  final Failure failure;

  @override
  List<Object?> get props => [failure];
}
