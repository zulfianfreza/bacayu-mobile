import 'package:equatable/equatable.dart';

class ActivityComment extends Equatable {
  const ActivityComment({
    required this.id,
    required this.userId,
    required this.userName,
    required this.userAvatarUrl,
    required this.body,
    required this.createdAt,
  });

  final String id;
  final String userId;
  final String userName;
  final String? userAvatarUrl;
  final String body;
  final DateTime createdAt;

  @override
  List<Object?> get props => [id, userId, userName, userAvatarUrl, body, createdAt];
}
