import '../../domain/entities/activity_visibility.dart';

extension ActivityVisibilityWire on ActivityVisibility {
  String get wireValue => switch (this) {
        ActivityVisibility.private => 'private',
        ActivityVisibility.followers => 'followers',
        ActivityVisibility.public => 'public',
      };
}
