import 'package:equatable/equatable.dart';

class SessionStreak extends Equatable {
  const SessionStreak({
    required this.current,
    required this.longest,
    required this.extendedToday,
  });

  final int current;
  final int longest;
  final bool extendedToday;

  @override
  List<Object?> get props => [current, longest, extendedToday];
}
