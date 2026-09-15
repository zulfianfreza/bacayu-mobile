import 'package:equatable/equatable.dart';

import '../../../../core/error/failure.dart';
import '../../../auth/domain/entities/user.dart';

sealed class ProfileState extends Equatable {
  const ProfileState();

  @override
  List<Object?> get props => [];
}

class ProfileInitial extends ProfileState {
  const ProfileInitial();
}

class ProfileLoading extends ProfileState {
  const ProfileLoading();
}

class ProfileLoaded extends ProfileState {
  const ProfileLoaded({
    required this.user,
    required this.booksFinished,
    required this.badgesUnlocked,
    required this.totalBadges,
    required this.followersCount,
    required this.followingCount,
  });

  final User user;
  final int booksFinished;
  final int badgesUnlocked;
  final int totalBadges;
  final int followersCount;
  final int followingCount;

  @override
  List<Object?> get props => [
        user,
        booksFinished,
        badgesUnlocked,
        totalBadges,
        followersCount,
        followingCount,
      ];
}

class ProfileError extends ProfileState {
  const ProfileError(this.failure);

  final Failure failure;

  @override
  List<Object?> get props => [failure];
}
