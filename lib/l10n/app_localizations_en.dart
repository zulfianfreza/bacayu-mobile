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
}
