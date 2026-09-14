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
