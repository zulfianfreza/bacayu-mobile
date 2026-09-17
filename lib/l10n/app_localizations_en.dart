// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get retry => 'Retry';

  @override
  String get cancel => 'Cancel';

  @override
  String get save => 'Save';

  @override
  String get loading => 'Loading...';

  @override
  String get somethingWentWrong => 'Something went wrong. Please try again.';

  @override
  String get noInternetConnection =>
      'No internet connection. We\'ll retry automatically once you\'re back online.';

  @override
  String get fieldRequired => 'This field is required.';

  @override
  String get sessionNotFound => 'Reading session not found.';

  @override
  String get appName => 'BacaYu';

  @override
  String get email => 'Email';

  @override
  String get password => 'Password';

  @override
  String get name => 'Name';

  @override
  String get login => 'Log in';

  @override
  String get register => 'Sign up';

  @override
  String get welcomeBack => 'Welcome back';

  @override
  String get continueWithGoogle => 'Continue with Google';

  @override
  String get orDivider => 'or';

  @override
  String get createYourAccount => 'Create your account';

  @override
  String get dontHaveAccount => 'Don\'t have an account? Sign up';

  @override
  String get alreadyHaveAccount => 'Already have an account? Log in';

  @override
  String get emailAlreadyExists => 'This email is already registered.';

  @override
  String get invalidCredentials => 'Invalid email or password.';

  @override
  String get sessionExpired => 'Session expired. Please sign in again.';

  @override
  String get searchBooksHint => 'Search by title, author, or ISBN';

  @override
  String get scanBarcode => 'Scan barcode';

  @override
  String get scanIsbnGuide => 'Line up the barcode inside the frame';

  @override
  String get addToShelf => 'Add to shelf';

  @override
  String get bookAddedToShelf => 'Added to your shelf.';

  @override
  String get noSearchResults => 'No books found. Try a different search.';

  @override
  String pagesCount(int pages) {
    return '$pages pages';
  }

  @override
  String byAuthor(String authors) {
    return 'by $authors';
  }

  @override
  String get bookNotFound => 'Book not found.';

  @override
  String get alreadyInShelf => 'This book is already in your shelf.';

  @override
  String get shelfTitle => 'My shelf';

  @override
  String get filterAll => 'All';

  @override
  String get statusWantToRead => 'Want to read';

  @override
  String get statusReading => 'Reading';

  @override
  String get statusFinished => 'Finished';

  @override
  String get statusDnf => 'DNF';

  @override
  String get changeStatus => 'Change status';

  @override
  String get emptyShelfHeadline => 'Your shelf is empty';

  @override
  String get emptyShelfBody => 'Add your first book to start tracking';

  @override
  String get addABook => 'Add a book';

  @override
  String pageProgress(int current, int total) {
    return 'Page $current of $total';
  }

  @override
  String get onboardingWelcomeHeadline =>
      'Track your reading like Strava tracks your run';

  @override
  String get getStarted => 'Get started';

  @override
  String get iAlreadyHaveAnAccount => 'I already have an account';

  @override
  String get whatDoYouLoveReading => 'What do you love reading?';

  @override
  String get yearlyReadingGoal => 'Yearly reading goal';

  @override
  String booksPerYear(int count) {
    return '$count books/year';
  }

  @override
  String get continueLabel => 'Continue';

  @override
  String get addFirstBookHeadline => 'Add your first book to your shelf';

  @override
  String get searchTitleOrAuthorHint => 'Search title or author';

  @override
  String get scanIsbn => 'Scan ISBN';

  @override
  String get addManually => 'Add manually';

  @override
  String get illDoThisLater => 'I\'ll do this later';

  @override
  String get bookTitle => 'Title';

  @override
  String get bookAuthors => 'Authors';

  @override
  String get bookTotalPages => 'Total pages';

  @override
  String get genreFiction => 'Fiction';

  @override
  String get genreNonFiction => 'Non-fiction';

  @override
  String get genreFantasy => 'Fantasy';

  @override
  String get genreRomance => 'Romance';

  @override
  String get genreSelfHelp => 'Self-help';

  @override
  String get genreComics => 'Comics';

  @override
  String get genreMystery => 'Mystery';

  @override
  String get genreBiography => 'Biography';

  @override
  String get genreSciFi => 'Sci-fi';

  @override
  String get genrePoetry => 'Poetry';

  @override
  String get whatAreYouReading => 'What are you reading?';

  @override
  String get noReadingBooks =>
      'No books in progress. Add one to your shelf first.';

  @override
  String get bookPickerSubtitle =>
      'Pick the book you\'re reading now to start a session.';

  @override
  String get timeJustNow => 'Just now';

  @override
  String timeMinutesAgo(int count) {
    return '${count}m ago';
  }

  @override
  String timeHoursAgo(int count) {
    return '${count}h ago';
  }

  @override
  String timeDaysAgo(int count) {
    return '${count}d ago';
  }

  @override
  String pausesSoFar(int count) {
    return '$count pauses so far';
  }

  @override
  String get sessionSummary => 'Session summary';

  @override
  String get totalDuration => 'Total duration';

  @override
  String get startPage => 'Start page';

  @override
  String get endPage => 'End page';

  @override
  String get saveSession => 'Save session';

  @override
  String get sessionSaved => 'Session saved';

  @override
  String get newBadge => 'New badge!';

  @override
  String get tabHome => 'Home';

  @override
  String get tabShelf => 'Shelf';

  @override
  String get tabStats => 'Stats';

  @override
  String get tabProfile => 'Profile';

  @override
  String get comingSoon => 'Coming soon';

  @override
  String get startSession => 'Start session';

  @override
  String get yourStats => 'Your stats';

  @override
  String get rangeWeek => 'This week';

  @override
  String get rangeMonth => 'This month';

  @override
  String get rangeYear => 'This year';

  @override
  String get rangeAll => 'All time';

  @override
  String get metricBooksFinished => 'Books finished';

  @override
  String get metricPagesRead => 'Pages read';

  @override
  String get metricTimeReading => 'Time reading';

  @override
  String get metricAvgSpeed => 'Avg. speed (ppm)';

  @override
  String get yourBadges => 'Your badges';

  @override
  String get seeAll => 'See all';

  @override
  String get noBadgesYet => 'No badges yet — keep reading!';

  @override
  String get badgeGalleryTitle => 'Your badges';

  @override
  String get awesome => 'Awesome!';

  @override
  String get feedTitle => 'Activity';

  @override
  String get feedEmpty =>
      'No activity yet — start a reading session to see it here.';

  @override
  String get activityNotAvailable => 'This activity isn\'t available.';

  @override
  String speedPpmValue(String speed) {
    return '$speed ppm';
  }

  @override
  String homeGreeting(String name) {
    return 'Hi, $name';
  }

  @override
  String get dayStreak => 'day streak';

  @override
  String get viewFullHeatmap => 'View full heatmap';

  @override
  String get continueReading => 'Continue reading';

  @override
  String get recentActivity => 'Recent activity';

  @override
  String get viewAllActivity => 'View all';

  @override
  String get startFirstSessionCta => 'Start your first reading session';

  @override
  String get startFirstSessionBody =>
      'Pick a book from your shelf and start your first timer.';

  @override
  String get followersTitle => 'Followers';

  @override
  String get followingTitle => 'Following';

  @override
  String get leaderboardTitle => 'Leaderboard';

  @override
  String get follow => 'Follow';

  @override
  String get followingButton => 'Following';

  @override
  String get noFollowers => 'No followers yet';

  @override
  String get noFollowing => 'Not following anyone yet';

  @override
  String get yourPosition => 'Your position';

  @override
  String get addCommentHint => 'Add a comment...';

  @override
  String get postComment => 'Post';

  @override
  String get noComments => 'No comments yet';

  @override
  String get changeVisibility => 'Change visibility';

  @override
  String get visibilityPrivate => 'Private';

  @override
  String get visibilityFollowers => 'Followers';

  @override
  String get visibilityPublic => 'Public';

  @override
  String get visibilityUpdated => 'Visibility updated.';

  @override
  String get cannotFollowSelf => 'You can\'t follow yourself.';

  @override
  String get alreadyLiked => 'Already liked.';

  @override
  String get profileStatsBooks => 'Books';

  @override
  String get profileStatsStreak => 'Streak';

  @override
  String get profileStatsBadges => 'Badges';

  @override
  String profileFollowersCount(int count) {
    return '$count Followers';
  }

  @override
  String profileFollowingCount(int count) {
    return '$count Following';
  }

  @override
  String get readingGoals => 'Reading goals';

  @override
  String get dailyReadingGoal => 'Daily reading goal';

  @override
  String minutesPerDay(int count) {
    return '$count min/day';
  }

  @override
  String get goalsUpdated => 'Goals updated.';

  @override
  String get language => 'Language';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageIndonesian => 'Bahasa Indonesia';

  @override
  String get privacy => 'Privacy';

  @override
  String get helpAndSupport => 'Help and support';

  @override
  String get helpAndSupportBody =>
      'Need help? Email us at support@bacayu.app and we\'ll get back to you.';

  @override
  String get logOut => 'Log out';

  @override
  String get logOutConfirmTitle => 'Log out?';

  @override
  String get logOutConfirmBody => 'You\'ll need to log in again to continue.';

  @override
  String get share => 'Share';

  @override
  String get download => 'Download';

  @override
  String get shareSession => 'Share session';

  @override
  String get savedToGallery => 'Saved to gallery';

  @override
  String get shareFailed => 'Couldn\'t share. Please try again.';

  @override
  String get saveImageFailed => 'Couldn\'t save the image.';

  @override
  String streakDaysChip(int count) {
    return '🔥 $count day streak';
  }

  @override
  String get shareStatTime => 'Time';

  @override
  String get shareStatPages => 'Pages';

  @override
  String get shareStatSpeed => 'Speed';

  @override
  String get shareStickerHint =>
      'Transparent sticker. Place it over your own photo.';
}
