import 'package:equatable/equatable.dart';

class FollowCounts extends Equatable {
  const FollowCounts({required this.followers, required this.following});

  final int followers;
  final int following;

  @override
  List<Object?> get props => [followers, following];
}
