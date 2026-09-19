import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_id.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('id'),
  ];

  /// Button label to retry a failed action
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// Button label to cancel/dismiss an action
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// Button label to save/confirm an action
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// Generic loading indicator label
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// Generic fallback error message
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please try again.'**
  String get somethingWentWrong;

  /// Shown when a request fails due to no network connectivity
  ///
  /// In en, this message translates to:
  /// **'No internet connection. We\'ll retry automatically once you\'re back online.'**
  String get noInternetConnection;

  /// Generic required-field validation message for any form
  ///
  /// In en, this message translates to:
  /// **'This field is required.'**
  String get fieldRequired;

  /// Backend error SESSION_NOT_FOUND, localized
  ///
  /// In en, this message translates to:
  /// **'Reading session not found.'**
  String get sessionNotFound;

  /// Product name, shown on auth screens
  ///
  /// In en, this message translates to:
  /// **'BacaYu'**
  String get appName;

  /// Email field label
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// Password field label
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// Full name field label, used at registration
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get name;

  /// Login button label
  ///
  /// In en, this message translates to:
  /// **'Log in'**
  String get login;

  /// Register/sign up button label
  ///
  /// In en, this message translates to:
  /// **'Sign up'**
  String get register;

  /// Login page headline
  ///
  /// In en, this message translates to:
  /// **'Welcome back'**
  String get welcomeBack;

  /// Google Sign-In button label — handles both register and login (backend find-or-create), so there's only ever this one button, never separate 'sign up with Google' / 'log in with Google' labels
  ///
  /// In en, this message translates to:
  /// **'Continue with Google'**
  String get continueWithGoogle;

  /// Divider label between the email/password form and the Google Sign-In button on the login page
  ///
  /// In en, this message translates to:
  /// **'or'**
  String get orDivider;

  /// Register page headline
  ///
  /// In en, this message translates to:
  /// **'Create your account'**
  String get createYourAccount;

  /// Link on the login page to go to registration
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account? Sign up'**
  String get dontHaveAccount;

  /// Link on the register page to go to login
  ///
  /// In en, this message translates to:
  /// **'Already have an account? Log in'**
  String get alreadyHaveAccount;

  /// Backend error EMAIL_ALREADY_EXISTS, localized
  ///
  /// In en, this message translates to:
  /// **'This email is already registered.'**
  String get emailAlreadyExists;

  /// Backend error INVALID_CREDENTIALS, localized
  ///
  /// In en, this message translates to:
  /// **'Invalid email or password.'**
  String get invalidCredentials;

  /// Shown once on LoginPage after an auto-logout triggered by a 401 (SessionExpiredFailure) — also SessionExpiredFailure's generic localized message
  ///
  /// In en, this message translates to:
  /// **'Session expired. Please sign in again.'**
  String get sessionExpired;

  /// Book search field placeholder
  ///
  /// In en, this message translates to:
  /// **'Search by title, author, or ISBN'**
  String get searchBooksHint;

  /// Button that opens the ISBN barcode scanner
  ///
  /// In en, this message translates to:
  /// **'Scan barcode'**
  String get scanBarcode;

  /// Instruction text under the scanner guide box
  ///
  /// In en, this message translates to:
  /// **'Line up the barcode inside the frame'**
  String get scanIsbnGuide;

  /// Button to add a looked-up/imported book to the user's shelf
  ///
  /// In en, this message translates to:
  /// **'Add to shelf'**
  String get addToShelf;

  /// Confirmation after successfully adding a book to the shelf
  ///
  /// In en, this message translates to:
  /// **'Added to your shelf.'**
  String get bookAddedToShelf;

  /// Empty state for book search with no results
  ///
  /// In en, this message translates to:
  /// **'No books found. Try a different search.'**
  String get noSearchResults;

  /// Book page count, shown on a book result card
  ///
  /// In en, this message translates to:
  /// **'{pages} pages'**
  String pagesCount(int pages);

  /// Author line on a book result card
  ///
  /// In en, this message translates to:
  /// **'by {authors}'**
  String byAuthor(String authors);

  /// Backend error BOOK_NOT_FOUND, localized
  ///
  /// In en, this message translates to:
  /// **'Book not found.'**
  String get bookNotFound;

  /// Backend error ALREADY_IN_SHELF, localized
  ///
  /// In en, this message translates to:
  /// **'This book is already in your shelf.'**
  String get alreadyInShelf;

  /// Shelf page app bar title
  ///
  /// In en, this message translates to:
  /// **'My shelf'**
  String get shelfTitle;

  /// Shelf filter tab: no status filter
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get filterAll;

  /// Shelf status: want_to_read — used as both filter tab and status chip label
  ///
  /// In en, this message translates to:
  /// **'Want to read'**
  String get statusWantToRead;

  /// Shelf status: reading — used as both filter tab and status chip label
  ///
  /// In en, this message translates to:
  /// **'Reading'**
  String get statusReading;

  /// Shelf status: finished — used as both filter tab and status chip label
  ///
  /// In en, this message translates to:
  /// **'Finished'**
  String get statusFinished;

  /// Shelf status: dnf (did not finish) — used as both filter tab and status chip label
  ///
  /// In en, this message translates to:
  /// **'DNF'**
  String get statusDnf;

  /// Title of the bottom sheet opened by tapping a shelf book's status chip
  ///
  /// In en, this message translates to:
  /// **'Change status'**
  String get changeStatus;

  /// Shelf empty state headline
  ///
  /// In en, this message translates to:
  /// **'Your shelf is empty'**
  String get emptyShelfHeadline;

  /// Shelf empty state body text
  ///
  /// In en, this message translates to:
  /// **'Add your first book to start tracking'**
  String get emptyShelfBody;

  /// Shelf empty state CTA button
  ///
  /// In en, this message translates to:
  /// **'Add a book'**
  String get addABook;

  /// Reading progress caption under a Reading-status shelf card
  ///
  /// In en, this message translates to:
  /// **'Page {current} of {total}'**
  String pageProgress(int current, int total);

  /// Onboarding screen 1 headline
  ///
  /// In en, this message translates to:
  /// **'Track your reading like Strava tracks your run'**
  String get onboardingWelcomeHeadline;

  /// Onboarding screen 1 supporting text under the headline
  ///
  /// In en, this message translates to:
  /// **'Set a goal, log every session, and keep your streak alive.'**
  String get onboardingWelcomeBody;

  /// Onboarding screen 1 primary button
  ///
  /// In en, this message translates to:
  /// **'Get started'**
  String get getStarted;

  /// Onboarding screen 1 secondary link to login
  ///
  /// In en, this message translates to:
  /// **'I already have an account'**
  String get iAlreadyHaveAnAccount;

  /// Onboarding screen 2 heading
  ///
  /// In en, this message translates to:
  /// **'What do you love reading?'**
  String get whatDoYouLoveReading;

  /// Onboarding screen 2 goal stepper label
  ///
  /// In en, this message translates to:
  /// **'Yearly reading goal'**
  String get yearlyReadingGoal;

  /// Onboarding screen 2 goal stepper value
  ///
  /// In en, this message translates to:
  /// **'{count} books/year'**
  String booksPerYear(int count);

  /// Onboarding screen 2 primary button
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueLabel;

  /// Onboarding screen 3 heading
  ///
  /// In en, this message translates to:
  /// **'Add your first book to your shelf'**
  String get addFirstBookHeadline;

  /// Onboarding screen 3 search field placeholder
  ///
  /// In en, this message translates to:
  /// **'Search title or author'**
  String get searchTitleOrAuthorHint;

  /// Onboarding screen 3 quick-action button
  ///
  /// In en, this message translates to:
  /// **'Scan ISBN'**
  String get scanIsbn;

  /// Quick-action button / manual add sheet heading
  ///
  /// In en, this message translates to:
  /// **'Add manually'**
  String get addManually;

  /// Onboarding screen 3 skip link
  ///
  /// In en, this message translates to:
  /// **'I\'ll do this later'**
  String get illDoThisLater;

  /// Manual add book form: title field
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get bookTitle;

  /// Manual add book form: authors field (comma-separated)
  ///
  /// In en, this message translates to:
  /// **'Authors'**
  String get bookAuthors;

  /// Manual add book form: total pages field
  ///
  /// In en, this message translates to:
  /// **'Total pages'**
  String get bookTotalPages;

  /// No description provided for @genreFiction.
  ///
  /// In en, this message translates to:
  /// **'Fiction'**
  String get genreFiction;

  /// No description provided for @genreNonFiction.
  ///
  /// In en, this message translates to:
  /// **'Non-fiction'**
  String get genreNonFiction;

  /// No description provided for @genreFantasy.
  ///
  /// In en, this message translates to:
  /// **'Fantasy'**
  String get genreFantasy;

  /// No description provided for @genreRomance.
  ///
  /// In en, this message translates to:
  /// **'Romance'**
  String get genreRomance;

  /// No description provided for @genreSelfHelp.
  ///
  /// In en, this message translates to:
  /// **'Self-help'**
  String get genreSelfHelp;

  /// No description provided for @genreComics.
  ///
  /// In en, this message translates to:
  /// **'Comics'**
  String get genreComics;

  /// No description provided for @genreMystery.
  ///
  /// In en, this message translates to:
  /// **'Mystery'**
  String get genreMystery;

  /// No description provided for @genreBiography.
  ///
  /// In en, this message translates to:
  /// **'Biography'**
  String get genreBiography;

  /// No description provided for @genreSciFi.
  ///
  /// In en, this message translates to:
  /// **'Sci-fi'**
  String get genreSciFi;

  /// No description provided for @genrePoetry.
  ///
  /// In en, this message translates to:
  /// **'Poetry'**
  String get genrePoetry;

  /// Book picker bottom sheet heading, before starting a reading session
  ///
  /// In en, this message translates to:
  /// **'What are you reading?'**
  String get whatAreYouReading;

  /// Book picker empty state — no shelf entries with status Reading
  ///
  /// In en, this message translates to:
  /// **'No books in progress. Add one to your shelf first.'**
  String get noReadingBooks;

  /// Supporting line under the book picker heading
  ///
  /// In en, this message translates to:
  /// **'Pick the book you\'re reading now to start a session.'**
  String get bookPickerSubtitle;

  /// Relative timestamp on an activity posted less than a minute ago
  ///
  /// In en, this message translates to:
  /// **'Just now'**
  String get timeJustNow;

  /// Relative timestamp on an activity, in minutes
  ///
  /// In en, this message translates to:
  /// **'{count}m ago'**
  String timeMinutesAgo(int count);

  /// Relative timestamp on an activity, in hours
  ///
  /// In en, this message translates to:
  /// **'{count}h ago'**
  String timeHoursAgo(int count);

  /// Relative timestamp on an activity, in days
  ///
  /// In en, this message translates to:
  /// **'{count}d ago'**
  String timeDaysAgo(int count);

  /// Caption under the running/paused session timer
  ///
  /// In en, this message translates to:
  /// **'{count} pauses so far'**
  String pausesSoFar(int count);

  /// Session summary page app bar title
  ///
  /// In en, this message translates to:
  /// **'Session summary'**
  String get sessionSummary;

  /// Session summary card label
  ///
  /// In en, this message translates to:
  /// **'Total duration'**
  String get totalDuration;

  /// Session summary start page field label
  ///
  /// In en, this message translates to:
  /// **'Start page'**
  String get startPage;

  /// Session summary end page field label
  ///
  /// In en, this message translates to:
  /// **'End page'**
  String get endPage;

  /// Session summary primary button
  ///
  /// In en, this message translates to:
  /// **'Save session'**
  String get saveSession;

  /// Session summary button label after a successful submit
  ///
  /// In en, this message translates to:
  /// **'Session saved'**
  String get sessionSaved;

  /// App bar title of the timer/manual choice page
  ///
  /// In en, this message translates to:
  /// **'Log a session'**
  String get sessionModeTitle;

  /// Headline of the timer/manual choice page
  ///
  /// In en, this message translates to:
  /// **'How do you want to log this?'**
  String get chooseSessionMode;

  /// Choice page — live timer option
  ///
  /// In en, this message translates to:
  /// **'Start timer'**
  String get startTimerOption;

  /// Choice page — supporting text under the timer option
  ///
  /// In en, this message translates to:
  /// **'Track it live while you read.'**
  String get startTimerOptionBody;

  /// Choice page — supporting text under the manual option
  ///
  /// In en, this message translates to:
  /// **'Read without the timer? Enter the pages and how long it took.'**
  String get addManualOptionBody;

  /// App bar title of the manual session form
  ///
  /// In en, this message translates to:
  /// **'Manual session'**
  String get manualSessionTitle;

  /// Manual session form — date field label
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get dateLabel;

  /// Manual session form — shown instead of a date when the day is today
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get todayLabel;

  /// Manual session form — duration field label
  ///
  /// In en, this message translates to:
  /// **'Duration'**
  String get durationLabel;

  /// Manual session form — unit suffix next to the duration field
  ///
  /// In en, this message translates to:
  /// **'min'**
  String get minutesShort;

  /// Manual session form — validation error for a missing/zero duration
  ///
  /// In en, this message translates to:
  /// **'Enter how long you read.'**
  String get invalidDuration;

  /// Manual session form — validation error; the backend also rejects end_page <= start_page
  ///
  /// In en, this message translates to:
  /// **'The end page has to be after the start page.'**
  String get invalidPageRange;

  /// Celebratory banner heading when a session unlocks a badge
  ///
  /// In en, this message translates to:
  /// **'New badge!'**
  String get newBadge;

  /// Bottom nav tab label
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get tabHome;

  /// Bottom nav tab label
  ///
  /// In en, this message translates to:
  /// **'Shelf'**
  String get tabShelf;

  /// Bottom nav tab label
  ///
  /// In en, this message translates to:
  /// **'Stats'**
  String get tabStats;

  /// Bottom nav tab label
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get tabProfile;

  /// Placeholder body text for a tab not built yet
  ///
  /// In en, this message translates to:
  /// **'Coming soon'**
  String get comingSoon;

  /// FAB tooltip — opens the book picker to start a reading session
  ///
  /// In en, this message translates to:
  /// **'Start session'**
  String get startSession;

  /// Stats page app bar title
  ///
  /// In en, this message translates to:
  /// **'Your stats'**
  String get yourStats;

  /// Stats range segmented control option
  ///
  /// In en, this message translates to:
  /// **'This week'**
  String get rangeWeek;

  /// Stats range segmented control option
  ///
  /// In en, this message translates to:
  /// **'This month'**
  String get rangeMonth;

  /// Stats range segmented control option
  ///
  /// In en, this message translates to:
  /// **'This year'**
  String get rangeYear;

  /// Stats range segmented control option
  ///
  /// In en, this message translates to:
  /// **'All time'**
  String get rangeAll;

  /// Stats metric card label
  ///
  /// In en, this message translates to:
  /// **'Books finished'**
  String get metricBooksFinished;

  /// Stats metric card label
  ///
  /// In en, this message translates to:
  /// **'Pages read'**
  String get metricPagesRead;

  /// Stats metric card label
  ///
  /// In en, this message translates to:
  /// **'Time reading'**
  String get metricTimeReading;

  /// Stats metric card label
  ///
  /// In en, this message translates to:
  /// **'Avg. speed (ppm)'**
  String get metricAvgSpeed;

  /// Stats page section title above the full-year heatmap
  ///
  /// In en, this message translates to:
  /// **'Reading activity'**
  String get statsHeatmapTitle;

  /// Stats page section title above the genre bar chart
  ///
  /// In en, this message translates to:
  /// **'Favorite genres'**
  String get statsGenresTitle;

  /// Badge preview row heading on the stats page
  ///
  /// In en, this message translates to:
  /// **'Your badges'**
  String get yourBadges;

  /// Link to the full badge collection (not built yet)
  ///
  /// In en, this message translates to:
  /// **'See all'**
  String get seeAll;

  /// Badge preview row empty state
  ///
  /// In en, this message translates to:
  /// **'No badges yet — keep reading!'**
  String get noBadgesYet;

  /// Badge gallery page app bar title
  ///
  /// In en, this message translates to:
  /// **'Your badges'**
  String get badgeGalleryTitle;

  /// Dismiss button on the badge-unlocked modal
  ///
  /// In en, this message translates to:
  /// **'Awesome!'**
  String get awesome;

  /// ActivityDetailPage fallback when reached without the Activity in memory (e.g. a future deep link) — there's no fetch-by-id endpoint yet, only the feed list
  ///
  /// In en, this message translates to:
  /// **'This activity isn\'t available.'**
  String get activityNotAvailable;

  /// Book detail page — heading of the description card
  ///
  /// In en, this message translates to:
  /// **'Synopsis'**
  String get bookSynopsis;

  /// Reading speed shown on a session activity card
  ///
  /// In en, this message translates to:
  /// **'{speed} ppm'**
  String speedPpmValue(String speed);

  /// Home page header greeting
  ///
  /// In en, this message translates to:
  /// **'Hi, {name}'**
  String homeGreeting(String name);

  /// Label under the big streak number on the home page
  ///
  /// In en, this message translates to:
  /// **'day streak'**
  String get dayStreak;

  /// Secondary line on the home page streak card, next to the current streak
  ///
  /// In en, this message translates to:
  /// **'Longest: {count} days'**
  String longestStreakDays(int count);

  /// Link under the home page's 7-day heatmap strip, opens Stats
  ///
  /// In en, this message translates to:
  /// **'View full heatmap'**
  String get viewFullHeatmap;

  /// Left end of the heatmap legend, next to the palest swatch
  ///
  /// In en, this message translates to:
  /// **'Less'**
  String get heatmapLess;

  /// Right end of the heatmap legend, next to the darkest swatch
  ///
  /// In en, this message translates to:
  /// **'More'**
  String get heatmapMore;

  /// Home page section heading
  ///
  /// In en, this message translates to:
  /// **'Continue reading'**
  String get continueReading;

  /// Home page section heading
  ///
  /// In en, this message translates to:
  /// **'Recent activity'**
  String get recentActivity;

  /// Home page empty social feed — headline of the find-friends call to action
  ///
  /// In en, this message translates to:
  /// **'Find reading friends'**
  String get findFriendsHeadline;

  /// Home page empty social feed — supporting text
  ///
  /// In en, this message translates to:
  /// **'Follow people to see what they\'re reading. Their activity shows up here.'**
  String get findFriendsBody;

  /// Home page empty social feed — CTA button, opens the leaderboard
  ///
  /// In en, this message translates to:
  /// **'Find friends'**
  String get findFriends;

  /// Followers page app bar title
  ///
  /// In en, this message translates to:
  /// **'Followers'**
  String get followersTitle;

  /// Following page app bar title
  ///
  /// In en, this message translates to:
  /// **'Following'**
  String get followingTitle;

  /// Leaderboard page app bar title
  ///
  /// In en, this message translates to:
  /// **'Leaderboard'**
  String get leaderboardTitle;

  /// Follow button label (not yet following)
  ///
  /// In en, this message translates to:
  /// **'Follow'**
  String get follow;

  /// Follow button label when already following (tap to unfollow)
  ///
  /// In en, this message translates to:
  /// **'Following'**
  String get followingButton;

  /// Followers page empty state
  ///
  /// In en, this message translates to:
  /// **'No followers yet'**
  String get noFollowers;

  /// Following page empty state
  ///
  /// In en, this message translates to:
  /// **'Not following anyone yet'**
  String get noFollowing;

  /// Divider label above the current user's own row on the leaderboard, when outside the top N
  ///
  /// In en, this message translates to:
  /// **'Your position'**
  String get yourPosition;

  /// Comments bottom sheet text field placeholder
  ///
  /// In en, this message translates to:
  /// **'Add a comment...'**
  String get addCommentHint;

  /// Comments bottom sheet heading
  ///
  /// In en, this message translates to:
  /// **'Comments'**
  String get commentsTitle;

  /// Comments bottom sheet send button
  ///
  /// In en, this message translates to:
  /// **'Post'**
  String get postComment;

  /// Comments bottom sheet empty state
  ///
  /// In en, this message translates to:
  /// **'No comments yet'**
  String get noComments;

  /// Overflow menu option on your own activity card
  ///
  /// In en, this message translates to:
  /// **'Change visibility'**
  String get changeVisibility;

  /// Activity visibility option
  ///
  /// In en, this message translates to:
  /// **'Private'**
  String get visibilityPrivate;

  /// Activity visibility option
  ///
  /// In en, this message translates to:
  /// **'Followers'**
  String get visibilityFollowers;

  /// Activity visibility option
  ///
  /// In en, this message translates to:
  /// **'Public'**
  String get visibilityPublic;

  /// Confirmation after changing an activity's visibility
  ///
  /// In en, this message translates to:
  /// **'Visibility updated.'**
  String get visibilityUpdated;

  /// Backend error CANNOT_FOLLOW_SELF, localized
  ///
  /// In en, this message translates to:
  /// **'You can\'t follow yourself.'**
  String get cannotFollowSelf;

  /// Backend error ALREADY_LIKED, localized
  ///
  /// In en, this message translates to:
  /// **'Already liked.'**
  String get alreadyLiked;

  /// Profile page stats row — books finished column label
  ///
  /// In en, this message translates to:
  /// **'Books'**
  String get profileStatsBooks;

  /// Profile page stats row — current streak column label
  ///
  /// In en, this message translates to:
  /// **'Streak'**
  String get profileStatsStreak;

  /// Profile page stats row — badges unlocked column label
  ///
  /// In en, this message translates to:
  /// **'Badges'**
  String get profileStatsBadges;

  /// Profile page followers count, tap navigates to FollowersPage
  ///
  /// In en, this message translates to:
  /// **'{count} Followers'**
  String profileFollowersCount(int count);

  /// Profile page following count, tap navigates to FollowingPage
  ///
  /// In en, this message translates to:
  /// **'{count} Following'**
  String profileFollowingCount(int count);

  /// Profile settings list item — navigates to ReadingGoalsPage
  ///
  /// In en, this message translates to:
  /// **'Reading goals'**
  String get readingGoals;

  /// Reading goals page — daily minutes stepper label
  ///
  /// In en, this message translates to:
  /// **'Daily reading goal'**
  String get dailyReadingGoal;

  /// Reading goals page — daily minutes stepper value
  ///
  /// In en, this message translates to:
  /// **'{count} min/day'**
  String minutesPerDay(int count);

  /// Confirmation after saving reading goals
  ///
  /// In en, this message translates to:
  /// **'Goals updated.'**
  String get goalsUpdated;

  /// Profile settings list item — opens the language picker
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// Language picker option
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// Language picker option
  ///
  /// In en, this message translates to:
  /// **'Bahasa Indonesia'**
  String get languageIndonesian;

  /// Profile settings list item — opens the default activity privacy picker
  ///
  /// In en, this message translates to:
  /// **'Privacy'**
  String get privacy;

  /// Profile settings list item — navigates to HelpSupportPage
  ///
  /// In en, this message translates to:
  /// **'Help and support'**
  String get helpAndSupport;

  /// Help and support page body text
  ///
  /// In en, this message translates to:
  /// **'Need help? Email us at support@bacayu.app and we\'ll get back to you.'**
  String get helpAndSupportBody;

  /// Profile settings list item — clears the session
  ///
  /// In en, this message translates to:
  /// **'Log out'**
  String get logOut;

  /// Log out confirmation dialog title
  ///
  /// In en, this message translates to:
  /// **'Log out?'**
  String get logOutConfirmTitle;

  /// Log out confirmation dialog body
  ///
  /// In en, this message translates to:
  /// **'You\'ll need to log in again to continue.'**
  String get logOutConfirmBody;

  /// Button that opens the native share sheet
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get share;

  /// Button that saves the shareable card image to the gallery
  ///
  /// In en, this message translates to:
  /// **'Download'**
  String get download;

  /// Share preview sheet heading
  ///
  /// In en, this message translates to:
  /// **'Share session'**
  String get shareSession;

  /// Confirmation snackbar after a shareable card is saved to the device gallery
  ///
  /// In en, this message translates to:
  /// **'Saved to gallery'**
  String get savedToGallery;

  /// Snackbar when handing the card to the native share sheet fails
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t share. Please try again.'**
  String get shareFailed;

  /// Snackbar when saving the shareable card to the gallery fails
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t save the image.'**
  String get saveImageFailed;

  /// Streak badge on a shareable session card
  ///
  /// In en, this message translates to:
  /// **'🔥 {count} day streak'**
  String streakDaysChip(int count);

  /// Label above the session duration on a shareable session card
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get shareStatTime;

  /// Label above the page count on a shareable session card
  ///
  /// In en, this message translates to:
  /// **'Pages'**
  String get shareStatPages;

  /// Label above the reading speed on a shareable session card
  ///
  /// In en, this message translates to:
  /// **'Speed'**
  String get shareStatSpeed;

  /// Explanation shown while previewing the transparent preset of the shareable card
  ///
  /// In en, this message translates to:
  /// **'Transparent sticker. Place it over your own photo.'**
  String get shareStickerHint;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'id'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'id':
      return AppLocalizationsId();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
