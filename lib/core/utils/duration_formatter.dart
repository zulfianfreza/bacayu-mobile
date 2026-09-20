/// `MM:SS`, or `HH:MM:SS` once the session runs an hour or more.
String formatSessionDuration(Duration duration) {
  final hours = duration.inHours;
  final minutes = duration.inMinutes.remainder(60);
  final seconds = duration.inSeconds.remainder(60);
  final mm = minutes.toString().padLeft(2, '0');
  final ss = seconds.toString().padLeft(2, '0');
  return hours > 0 ? '${hours.toString().padLeft(2, '0')}:$mm:$ss' : '$mm:$ss';
}

/// `1h 46m 7s` — the unit-suffixed way Strava states a moving time, for places
/// that spell the units out instead of running a clock: `2h 5m`, `46m 7s`,
/// `12s`.
///
/// A unit the duration never reaches is dropped, and so are trailing zero
/// seconds, so half an hour reads `30m` rather than `30m 0s`. A middle unit is
/// never skipped, though — `1h 7s` would be too easy to misread as a minute
/// value.
String formatSessionDurationWords(Duration duration) {
  final hours = duration.inHours;
  final minutes = duration.inMinutes.remainder(60);
  final seconds = duration.inSeconds.remainder(60);

  final parts = <String>[
    if (hours > 0) '${hours}h',
    if (hours > 0 || minutes > 0) '${minutes}m',
  ];
  if (seconds > 0 || parts.isEmpty) parts.add('${seconds}s');

  return parts.join(' ');
}
