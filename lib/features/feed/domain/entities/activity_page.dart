import 'package:equatable/equatable.dart';

import 'activity.dart';

/// One page of activities plus the token for the next one.
///
/// The backend hands back an explicit `meta.next_cursor` (nil when the page it
/// just returned was the last one), so callers never have to infer "is there
/// more?" from how many items came back.
class ActivityPage extends Equatable {
  const ActivityPage({required this.items, required this.nextCursor});

  final List<Activity> items;

  /// Send back as the `cursor` query param to fetch the following page. `null`
  /// means this was the last page.
  final String? nextCursor;

  @override
  List<Object?> get props => [items, nextCursor];
}
